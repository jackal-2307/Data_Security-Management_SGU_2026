from pathlib import Path
import re
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Preformatted
from reportlab.lib.units import inch
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics

ROOT = Path(r'c:\Uni\Data_Security&Management_SGU_2026')
MD_PATH = ROOT / 'QuanLySinhVien_Report.md'
PDF_PATH = ROOT / 'QuanLySinhVien_Report.pdf'


def load_font():
    candidates = [
        Path(r'C:\Windows\Fonts\arial.ttf'),
        Path(r'C:\Windows\Fonts\tahoma.ttf'),
        Path(r'C:\Windows\Fonts\calibri.ttf'),
    ]
    for path in candidates:
        if path.exists():
            pdfmetrics.registerFont(TTFont('UnicodeFont', str(path)))
            return 'UnicodeFont'
    raise FileNotFoundError('No suitable Unicode TTF font found on this system.')

FONT_NAME = load_font()
code_font_path = Path(r'C:\Windows\Fonts\consola.ttf')
if code_font_path.exists():
    pdfmetrics.registerFont(TTFont('CodeFont', str(code_font_path)))
else:
    pdfmetrics.registerFont(TTFont('CodeFont', str(Path(r'C:\Windows\Fonts\cour.ttf'))))

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='TitleCustom', parent=styles['Title'], fontName=FONT_NAME, fontSize=24, leading=28, textColor='#1f2937', spaceAfter=16, alignment=1))
styles.add(ParagraphStyle(name='Heading1Custom', parent=styles['Heading1'], fontName=FONT_NAME, fontSize=18, leading=22, textColor='#1f3a5f', spaceBefore=10, spaceAfter=8))
styles.add(ParagraphStyle(name='Heading2Custom', parent=styles['Heading2'], fontName=FONT_NAME, fontSize=13, leading=18, textColor='#2c3e50', spaceBefore=8, spaceAfter=6))
styles.add(ParagraphStyle(name='BodyCustom', parent=styles['BodyText'], fontName=FONT_NAME, fontSize=10.5, leading=14, spaceAfter=6))
styles.add(ParagraphStyle(name='CodeCustom', parent=styles['Code'], fontName='CodeFont', fontSize=8.2, leading=10, backColor='#f3f4f6', borderPadding=8, borderWidth=1, borderColor='#d1d5db', leftIndent=8, rightIndent=8, spaceBefore=8, spaceAfter=8))


def render_markdown(md_text: str):
    lines = md_text.splitlines()
    story = []
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        if not line.strip():
            i += 1
            continue

        if line.startswith('```'):
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code_lines.append(lines[i])
                i += 1
            if i < len(lines):
                i += 1
            story.append(Preformatted('\n'.join(code_lines), styles['CodeCustom']))
            continue

        if line.startswith('!['):
            match = re.match(r'!\[[^\]]*\]\(([^)]+)\)', line)
            if match:
                img_path = (MD_PATH.parent / match.group(1)).resolve()
                if img_path.exists():
                    story.append(Spacer(1, 0.1 * inch))
                    story.append(Image(str(img_path), width=5.8 * inch, height=3.9 * inch, kind='proportional'))
                    i += 1
                    continue

        if line.startswith('# '):
            story.append(Paragraph(line[2:].strip(), styles['TitleCustom']))
            i += 1
            continue
        if line.startswith('## '):
            story.append(Paragraph(line[3:].strip(), styles['Heading1Custom']))
            i += 1
            continue
        if line.startswith('### '):
            story.append(Paragraph(line[4:].strip(), styles['Heading2Custom']))
            i += 1
            continue
        if line.startswith('- ') or line.startswith('* '):
            items = []
            while i < len(lines) and (lines[i].startswith('- ') or lines[i].startswith('* ')):
                items.append(lines[i][2:].strip())
                i += 1
            if items:
                story.append(Paragraph('<br/>'.join(f'• {txt}' for txt in items), styles['BodyCustom']))
            continue

        para_lines = [line]
        i += 1
        while i < len(lines):
            nxt = lines[i]
            if not nxt.strip() or nxt.startswith('```') or nxt.startswith('![') or nxt.startswith('# ') or nxt.startswith('## ') or nxt.startswith('### ') or nxt.startswith('- ') or nxt.startswith('* '):
                break
            para_lines.append(nxt)
            i += 1
        text = ' '.join(p.strip() for p in para_lines if p.strip())
        if text:
            story.append(Paragraph(text, styles['BodyCustom']))
    return story


def main():
    markdown = MD_PATH.read_text(encoding='utf-8')
    story = render_markdown(markdown)
    doc = SimpleDocTemplate(str(PDF_PATH), pagesize=letter, leftMargin=0.9 * inch, rightMargin=0.9 * inch, topMargin=0.8 * inch, bottomMargin=0.8 * inch)
    doc.build(story)
    print(f'Regenerated PDF: {PDF_PATH}')


if __name__ == '__main__':
    main()
