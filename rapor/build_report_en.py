#!/usr/bin/env python3
"""
Builds rapor/Rapor.docx (and optionally rapor/Ad_Soyad_Midterm.pdf) from rapor/Rapor.md.

Formatting rules (instructor's "General Guidelines for Written Reports"):
  - Times New Roman 12 pt, 1.5 line spacing, 1 inch (2.54 cm) margins on every side, A4
  - separate, centred cover page
  - numbered headings; table captions above tables, figure captions below figures
  - R code in a monospaced font (Courier New 10 pt)
  - APA 7 reference list with hanging indent

Usage (inside the rapor/ folder):
  python3 build_report.py          -> Rapor.docx
  python3 build_report.py --pdf    -> Rapor.docx + Ad_Soyad_Midterm.pdf (via Typst)
"""
import os, re, sys, shutil, subprocess, tempfile, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = "/usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64"   # pandoc + typst shipped with RStudio
PANDOC, TYPST = os.path.join(TOOLS, "pandoc"), os.path.join(TOOLS, "typst")
MD, DOCX, REF = "Rapor_EN.md", "Rapor_EN.docx", "reference_en.docx"
PDF = "Rapor_EN.pdf"

TNR = '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/>'
CNEW = '<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:eastAsia="Courier New" w:cs="Courier New"/>'
L15 = 'w:line="360" w:lineRule="auto"'      # 1.5 line spacing
L10 = 'w:line="240" w:lineRule="auto"'      # single spacing


def para_style(sid, name, based="Normal", ppr="", rpr="", custom=True, nxt=None):
    c = ' w:customStyle="1"' if custom else ""
    n = f'<w:next w:val="{nxt}"/>' if nxt else ""
    return (f'<w:style w:type="paragraph"{c} w:styleId="{sid}"><w:name w:val="{name}"/>'
            f'<w:basedOn w:val="{based}"/>{n}<w:qFormat/><w:pPr>{ppr}</w:pPr><w:rPr>{rpr}</w:rPr></w:style>')


def heading(level):
    return (f'<w:style w:type="paragraph" w:styleId="Heading{level}"><w:name w:val="heading {level}"/>'
            f'<w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/>'
            f'<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="120" {L15}/>'
            f'<w:outlineLvl w:val="{level-1}"/></w:pPr>'
            f'<w:rPr>{TNR}<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>')


def replace_style(styles, sid, new_xml):
    pat = re.compile(rf'<w:style [^>]*w:styleId="{sid}"[^>]*>.*?</w:style>', re.S)
    if pat.search(styles):
        return pat.sub(lambda m: new_xml, styles, count=1)
    return styles.replace("</w:styles>", new_xml + "</w:styles>")


def make_reference():
    tmp = tempfile.mkdtemp()
    default = os.path.join(tmp, "default.docx")
    subprocess.run([PANDOC, "-o", default, "--print-default-data-file", "reference.docx"], check=True)
    z = zipfile.ZipFile(default); items = {n: z.read(n) for n in z.namelist()}; z.close()
    st = items["word/styles.xml"].decode()

    # Document defaults: Times New Roman 12 pt, 1.5 spacing, Turkish
    st = re.sub(r'<w:docDefaults>.*?</w:docDefaults>',
                f'<w:docDefaults><w:rPrDefault><w:rPr>{TNR}<w:sz w:val="24"/><w:szCs w:val="24"/>'
                f'<w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>'
                f'<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="120" {L15}/></w:pPr></w:pPrDefault></w:docDefaults>',
                st, flags=re.S)
    body_ppr = f'<w:spacing w:before="0" w:after="120" {L15}/><w:jc w:val="both"/>'
    st = replace_style(st, "BodyText", para_style("BodyText", "Body Text", ppr=body_ppr, custom=False))
    st = replace_style(st, "FirstParagraph", para_style("FirstParagraph", "First Paragraph", "BodyText",
                                                        ppr=body_ppr, nxt="BodyText"))
    st = replace_style(st, "Compact", para_style("Compact", "Compact", "BodyText",
                                                 ppr=f'<w:spacing w:before="0" w:after="60" {L15}/><w:jc w:val="left"/>'))
    for lv in (1, 2, 3):
        st = replace_style(st, f"Heading{lv}", heading(lv))
    st = replace_style(st, "Caption", para_style("Caption", "caption", custom=False,
                                                 ppr=f'<w:spacing w:before="120" w:after="120" {L15}/>', rpr=''))
    st = replace_style(st, "TableCaption", para_style("TableCaption", "Table Caption", "Caption",
                                                      ppr=f'<w:keepNext/><w:spacing w:before="240" w:after="60" {L15}/>'))
    st = replace_style(st, "ImageCaption", para_style("ImageCaption", "Image Caption", "Caption",
                                                      ppr=f'<w:spacing w:before="60" w:after="240" {L15}/><w:jc w:val="center"/>'))
    st = replace_style(st, "CaptionedFigure", para_style("CaptionedFigure", "Captioned Figure", "Normal",
                                                         ppr='<w:keepNext/><w:spacing w:before="120" w:after="0"/><w:jc w:val="center"/>'))
    st = replace_style(st, "Figure", para_style("Figure", "Figure", "Normal",
                                                ppr='<w:keepNext/><w:jc w:val="center"/>'))
    # Table cells: 12 pt Times New Roman, single spacing (set on cell paragraphs after conversion)
    st = replace_style(st, "TableText", para_style("TableText", "Table Text", "Normal",
                                                   ppr=f'<w:spacing w:before="20" w:after="20" {L10}/>'))
    # R code: Courier New 10 pt, single spacing, light grey background
    st = replace_style(st, "SourceCode", para_style("SourceCode", "Source Code", "Normal",
                                                    ppr=f'<w:wordWrap w:val="off"/><w:spacing w:before="0" w:after="0" {L10}/>'
                                                        '<w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/>',
                                                    rpr=CNEW + '<w:sz w:val="18"/><w:szCs w:val="18"/>'))
    st = replace_style(st, "VerbatimChar",
                       f'<w:style w:type="character" w:customStyle="1" w:styleId="VerbatimChar"><w:name w:val="Verbatim Char"/>'
                       f'<w:rPr>{CNEW}<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>')
    # APA reference list: hanging indent 1.27 cm
    st = replace_style(st, "Bibliography", para_style("Bibliography", "Bibliography", custom=False,
                                                      ppr=f'<w:spacing w:before="0" w:after="120" {L15}/><w:ind w:left="720" w:hanging="720"/>'))
    # Cover page lines: centred
    st = replace_style(st, "CoverText", para_style("CoverText", "Cover Text",
                                                   ppr=f'<w:spacing w:before="0" w:after="0" {L15}/><w:jc w:val="center"/>'))
    # Table style: thin grey borders on every cell
    borders = ('<w:tblBorders>' + "".join(f'<w:{b} w:val="single" w:sz="4" w:space="0" w:color="808080"/>'
                                          for b in ("top", "left", "bottom", "right", "insideH", "insideV")) + '</w:tblBorders>')
    st = re.sub(r'(<w:style w:type="table" w:default="1" w:styleId="Table">.*?<w:tblPr>)', r'\1' + borders, st, count=1, flags=re.S)
    # Hyperlinks: black text (print friendly), keep Times New Roman
    st = replace_style(st, "Hyperlink", '<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/>'
                                        '<w:rPr><w:color w:val="000000"/></w:rPr></w:style>')
    items["word/styles.xml"] = st.encode()

    # Page setup: A4, 1 inch (1440 twips) margins, page number in the footer, no number on the cover page
    doc = items["word/document.xml"].decode()
    doc = doc.replace("<w:sectPr>", '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>'
                      '<w:pgSz w:w="11906" w:h="16838"/>'
                      '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="709" w:footer="709" w:gutter="0"/>'
                      '<w:titlePg/>', 1)
    if 'xmlns:r=' not in doc[:2000]:
        doc = doc.replace("<w:document ", '<w:document xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ', 1)
    items["word/document.xml"] = doc.encode()
    items["word/footer1.xml"] = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="0" w:after="0"/></w:pPr>'
        '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
        '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
        '</w:p></w:ftr>').encode()
    rels = items["word/_rels/document.xml.rels"].decode()
    rels = rels.replace("</Relationships>",
                        '<Relationship Id="rIdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" '
                        'Target="footer1.xml"/></Relationships>')
    items["word/_rels/document.xml.rels"] = rels.encode()
    ct = items["[Content_Types].xml"].decode()
    if "footer1.xml" not in ct:
        ct = ct.replace("</Types>", '<Override PartName="/word/footer1.xml" '
                        'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>')
    items["[Content_Types].xml"] = ct.encode()

    with zipfile.ZipFile(REF, "w", zipfile.ZIP_DEFLATED) as o:
        for n, b in items.items():
            o.writestr(n, b)
    shutil.rmtree(tmp)


def postprocess_docx():
    z = zipfile.ZipFile(DOCX); items = {n: z.read(n) for n in z.namelist()}; z.close()
    doc = items["word/document.xml"].decode()

    # 1) paragraphs inside tables -> TableText (single spacing, no justification)
    def fix_table(m):
        t = m.group(0)
        t = re.sub(r'<w:pStyle w:val="(Compact|BodyText|FirstParagraph)"\s*/>', '<w:pStyle w:val="TableText"/>', t)
        return t
    doc = re.sub(r'<w:tbl>.*?</w:tbl>', fix_table, doc, flags=re.S)

    # 1b) code blocks: every run inside a SourceCode paragraph in 9 pt
    def fix_code(m):
        return re.sub(r'<w:rPr>', '<w:rPr><w:sz w:val="18"/><w:szCs w:val="18"/>', m.group(0))
    doc = re.sub(r'<w:p>\s*<w:pPr>\s*<w:pStyle w:val="SourceCode"\s*/>.*?</w:p>', fix_code, doc, flags=re.S)

    # 2) page breaks before "1. Introduction" and "7. Appendix" (cover page stays alone on page 1)
    for title in ("1. Introduction", "7. Appendix – R Codes"):
        pat = re.compile(r'(<w:p>\s*<w:pPr>\s*<w:pStyle w:val="Heading1"\s*/>)((?:(?!</w:p>).)*?' + re.escape(title) + ')', re.S)
        doc, n = pat.subn(r'\1<w:pageBreakBefore/>\2', doc, count=1)
        assert n == 1, "heading not found: " + title

    # 3) the section properties from the reference doc (A4, margins, footer) must be on the final sectPr
    ref = zipfile.ZipFile(REF)
    ref_doc = ref.read("word/document.xml").decode(); ref.close()
    sect = re.search(r'<w:sectPr>.*?</w:sectPr>', ref_doc, re.S).group(0)
    doc = re.sub(r'<w:sectPr\b.*?</w:sectPr>', lambda m: sect, doc, count=1, flags=re.S)
    if 'xmlns:r=' not in doc[:3000]:
        doc = doc.replace("<w:document ", '<w:document xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ', 1)
    items["word/document.xml"] = doc.encode()

    # footer part + relationship must exist in the output package too
    ref = zipfile.ZipFile(REF)
    items["word/footer1.xml"] = ref.read("word/footer1.xml"); ref.close()
    rels = items["word/_rels/document.xml.rels"].decode()
    if "rIdFooter1" not in rels:
        rels = rels.replace("</Relationships>",
                            '<Relationship Id="rIdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" '
                            'Target="footer1.xml"/></Relationships>')
    items["word/_rels/document.xml.rels"] = rels.encode()
    ct = items["[Content_Types].xml"].decode()
    if "footer1.xml" not in ct:
        ct = ct.replace("</Types>", '<Override PartName="/word/footer1.xml" '
                        'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>')
    items["[Content_Types].xml"] = ct.encode()

    tmp = DOCX + ".tmp"
    with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as o:
        for n, b in items.items():
            o.writestr(n, b)
    os.replace(tmp, DOCX)


TYPST_PREAMBLE = r'''
#set document(title: "Data Mining Midterm Project")
#set page(paper: "a4", margin: 2.54cm, numbering: "1")
#set text(font: "Liberation Serif", size: 12pt, lang: "en")
#set par(justify: true, leading: 0.95em, spacing: 1.1em)
#show heading: set text(size: 12pt, weight: "bold")
#show heading: set block(above: 1.4em, below: 0.9em)
#show heading: set par(justify: false)
#show raw: set text(font: "Liberation Mono", size: 10pt)
#show raw.where(block: true): set text(size: 9pt)
#show raw.where(block: true): set par(leading: 0.45em, justify: false)
#show raw.where(block: true): it => block(fill: luma(242), inset: 4pt, width: 100%, breakable: true, it)
#show figure: set block(breakable: true)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set block(sticky: true)
#show figure.caption: it => block(width: 100%, align(left, text(size: 12pt, it.body)))
#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.where(kind: image): it => { it.body; align(center, text(size: 12pt, it.caption.body)) }
#set table(stroke: 0.5pt + luma(128), inset: 4pt)
#show table: set par(leading: 0.45em, justify: false)
#show link: set text(fill: black)
'''


def make_pdf():
    tmp = tempfile.mkdtemp()
    typ = os.path.join(tmp, "rapor.typ")
    body = subprocess.run([PANDOC, MD, "-t", "typst", "--resource-path=."], check=True,
                          capture_output=True, text=True).stdout
    figdir = os.path.abspath(os.path.join(HERE, "..", "output", "figures"))
    body = body.replace("../output/figures", figdir)
    # the cover page is a separate page without a page number; page numbering restarts at 1 afterwards
    body = body.replace("= 1. Introduction", "#pagebreak(weak: true)\n#counter(page).update(1)\n= 1. Introduction", 1)
    body = body.replace("= 7. Appendix -- R Codes", "#pagebreak(weak: true)\n= 7. Appendix -- R Codes", 1)
    assert body.count("#pagebreak(weak: true)") == 2, "page breaks not inserted"
    open(typ, "w").write(TYPST_PREAMBLE + body)
    subprocess.run([TYPST, "compile", "--root", "/", typ, os.path.join(HERE, PDF)], check=True)
    shutil.rmtree(tmp)


if __name__ == "__main__":
    os.chdir(HERE)
    make_reference()
    subprocess.run([PANDOC, MD, "-o", DOCX, "--resource-path=.", f"--reference-doc={REF}"], check=True)
    postprocess_docx()
    print("Written:", DOCX)
    if "--pdf" in sys.argv:
        make_pdf()
        print("Written:", PDF)
