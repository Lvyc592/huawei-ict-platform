#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# bootstrap: write the real copyright script
import os

lines = []
a = lines.append

a('#!/usr/bin/env python3')
a('# -*- coding: utf-8 -*-')
a('"""')
a('generate copyright doc for lab tracking system')
a('"""')
a('')
a('from docx import Document')
a('from docx.shared import Pt, Cm, RGBColor')
a('from docx.enum.text import WD_ALIGN_PARAGRAPH')
a('from docx.oxml.ns import qn')
a('from docx.oxml import OxmlElement')
a('from pathlib import Path')
a('')
a('BASE_DIR = Path("C:/Users/lv/Desktop/springboot-huawei-ict(1)/springboot-huawei-ict(1)")')
a('OUTPUT_PATH = BASE_DIR / "ruan_zhu_lab.docx"')
a('')
a('SOFTWARE_NAME = "huaji yun huawei cloud lab tracking system V1.0"')
a('LINES_PER_PAGE = 50')
a('MAX_TOTAL_PAGES = 60')
a('LINE_FONT_SIZE = Pt(8)')
a('LINE_SPACING = Pt(11.5)')
a('')
a('BACKEND_FILES = [')
for f in [
    "src/main/java/com/huawei/ict/IctApplication.java",
    "src/main/java/com/huawei/ict/config/SecurityConfig.java",
    "src/main/java/com/huawei/ict/config/JwtUtil.java",
    "src/main/java/com/huawei/ict/config/JwtAuthenticationFilter.java",
    "src/main/java/com/huawei/ict/config/AiProperties.java",
    "src/main/java/com/huawei/ict/dto/ApiResponse.java",
    "src/main/java/com/huawei/ict/dto/MyCourseDTO.java",
    "src/main/java/com/huawei/ict/dto/StudySuggestionDTO.java",
    "src/main/java/com/huawei/ict/dto/DashboardStats.java",
    "src/main/java/com/huawei/ict/entity/Lab.java",
    "src/main/java/com/huawei/ict/entity/LabInstance.java",
    "src/main/java/com/huawei/ict/entity/User.java",
    "src/main/java/com/huawei/ict/entity/Course.java",
    "src/main/java/com/huawei/ict/entity/CourseChapter.java",
    "src/main/java/com/huawei/ict/entity/Certification.java",
    "src/main/java/com/huawei/ict/entity/LearningRecord.java",
    "src/main/java/com/huawei/ict/entity/Notification.java",
    "src/main/java/com/huawei/ict/repository/LabRepository.java",
    "src/main/java/com/huawei/ict/repository/LabInstanceRepository.java",
    "src/main/java/com/huawei/ict/repository/UserRepository.java",
    "src/main/java/com/huawei/ict/repository/CourseRepository.java",
    "src/main/java/com/huawei/ict/service/LabService.java",
    "src/main/java/com/huawei/ict/service/DashboardService.java",
    "src/main/java/com/huawei/ict/service/CourseService.java",
    "src/main/java/com/huawei/ict/service/AuthService.java",
    "src/main/java/com/huawei/ict/service/NotificationService.java",
    "src/main/java/com/huawei/ict/service/AiService.java",
    "src/main/java/com/huawei/ict/controller/AdminController.java",
    "src/main/java/com/huawei/ict/controller/StudentController.java",
    "src/main/java/com/huawei/ict/controller/TeacherController.java",
    "src/main/java/com/huawei/ict/controller/AuthController.java",
    "src/main/java/com/huawei/ict/controller/AiChatController.java",
    "src/main/java/com/huawei/ict/controller/GlobalExceptionHandler.java",
]:
    a('    "{}",'.format(f))
a(']')
a('')
a('FRONTEND_FILES = [')
for f in [
    "src/main/resources/static/index.html",
    "src/main/resources/static/admin/dashboard.html",
    "src/main/resources/static/admin/labs.html",
    "src/main/resources/static/admin/courses.html",
    "src/main/resources/static/admin/users.html",
    "src/main/resources/static/admin/certifications.html",
    "src/main/resources/static/admin/analytics.html",
    "src/main/resources/static/admin/settings.html",
    "src/main/resources/static/teacher/dashboard.html",
    "src/main/resources/static/teacher/courses.html",
    "src/main/resources/static/teacher/students.html",
    "src/main/resources/static/teacher/analytics.html",
    "src/main/resources/static/teacher/exam-records.html",
    "src/main/resources/static/student/dashboard.html",
    "src/main/resources/static/student/cloud-lab.html",
    "src/main/resources/static/student/lab-env.html",
    "src/main/resources/static/student/lab-loading.html",
    "src/main/resources/static/student/courses.html",
    "src/main/resources/static/student/course-detail.html",
    "src/main/resources/static/student/ai-tutor.html",
    "src/main/resources/static/student/analytics.html",
]:
    a('    "{}",'.format(f))
a(']')
a('')
a('')
a('def add_page_number(paragraph):')
a('    run = paragraph.add_run()')
a('    fc1 = OxmlElement("w:fldChar")')
a('    fc1.set(qn("w:fldCharType"), "begin")')
a('    it = OxmlElement("w:instrText")')
a('    it.set(qn("xml:space"), "preserve")')
a('    it.text = "PAGE"')
a('    fc2 = OxmlElement("w:fldChar")')
a('    fc2.set(qn("w:fldCharType"), "end")')
a('    run._r.append(fc1)')
a('    run._r.append(it)')
a('    run._r.append(fc2)')
a('')
a('')
a('def is_bad_line(line):')
a('    s = line.strip()')
a('    if not s: return True')
a('    if s.startswith("//") or s.startswith("#"): return True')
a('    if s.startswith("/*") or s.startswith("*/"): return True')
a('    if s.startswith("/**") or s.startswith("*"): return True')
a('    if s.startswith("<!--") or s.startswith("-->"): return True')
a('    return False')
a('')
a('')
a('def read_valid(rel):')
a('    fp = BASE_DIR / rel')
a('    try:')
a('        with open(fp, "r", encoding="utf-8", errors="ignore") as f:')
a('            lines = f.readlines()')
a('        out = []')
a('        for line in lines:')
a('            if not is_bad_line(line):')
a('                out.append(line.rstrip("\\n").rstrip("\\r"))')
a('        return out')
a('    except Exception as e:')
a('        print("read fail:", rel, e)')
a('        return []')
a('')
a('')
a('def collect(files):')
a('    out = []')
a('    for rel in files:')
a('        ls = read_valid(rel)')
a('        for idx, line in enumerate(ls, 1):')
a('            out.append({"rel": rel, "no": idx, "txt": line})')
a('    return out')
a('')
a('')
a('def split_pages(all_lines, total=30):')
a('    half = total // 2')
a('    per_half = half * LINES_PER_PAGE')
a('    if len(all_lines) <= per_half * 2:')
a('        pages = []')
a('        for i in range(0, len(all_lines), LINES_PER_PAGE):')
a('            pages.append(all_lines[i:i+LINES_PER_PAGE])')
a('        return pages')
a('    front = all_lines[:per_half]')
a('    back = all_lines[-per_half:]')
a('    combined = front + back')
a('    pages = []')
a('    for i in range(0, len(combined), LINES_PER_PAGE):')
a('        pages.append(combined[i:i+LINES_PER_PAGE])')
a('    return pages')
a('')
a('')
a('def make_doc(bp, fp):')
a('    doc = Document()')
a('    sec = doc.sections[0]')
a('    sec.page_height = Cm(29.7)')
a('    sec.page_width = Cm(21.0)')
a('    sec.top_margin = Cm(2.0)')
a('    sec.bottom_margin = Cm(2.0)')
a('    sec.left_margin = Cm(2.0)')
a('    sec.right_margin = Cm(2.0)')
a('    # header')
a('    hdr = sec.header')
a('    hp = hdr.paragraphs[0]')
a('    hp.text = SOFTWARE_NAME')
a('    hp.alignment = WD_ALIGN_PARAGRAPH.CENTER')
a('    for r in hp.runs:')
a('        r.font.name = "SimSun"')
a('        r._element.rPr.rFonts.set(qn("w:eastAsia"), "SimSun")')
a('        r.font.size = Pt(10.5)')
a('        r.bold = True')
a('    # footer')
a('    ftr = sec.footer')
a('    fp_para = ftr.paragraphs[0]')
a('    fp_para.alignment = WD_ALIGN_PARAGRAPH.CENTER')
a('    fp_para.add_run("Page ")')
a('    add_page_number(fp_para)')
a('    fp_para.add_run(" of")')
a('    for r in fp_para.runs:')
a('        r.font.name = "SimSun"')
a('        r._element.rPr.rFonts.set(qn("w:eastAsia"), "SimSun")')
a('        r.font.size = Pt(10.5)')
a('    all_pages = bp + fp')
a('    for pi, plines in enumerate(all_pages):')
a('        if pi > 0:')
a('            doc.add_page_break()')
a('        first = plines[0]')
a('        last = plines[-1]')
a('        title = "Source: {} line {}".format(first["rel"], first["no"])')
a('        if first["rel"] == last["rel"]:')
a('            title += " to {}".format(last["no"])')
a('        else:')
a('            title += " ... {} line {}".format(last["rel"], last["no"])')
a('        tp = doc.add_paragraph()')
a('        tr = tp.add_run(title)')
a('        tr.font.name = "SimSun"')
a('        tr._element.rPr.rFonts.set(qn("w:eastAsia"), "SimSun")')
a('        tr.font.size = Pt(9)')
a('        tr.bold = True')
a('        tr.font.color.rgb = RGBColor(0x09, 0x40, 0x86)')
a('        tp.paragraph_format.space_before = Pt(0)')
a('        tp.paragraph_format.space_after = Pt(0)')
a('        tp.paragraph_format.line_spacing = LINE_SPACING')
a('        for item in plines:')
a('            p = doc.add_paragraph()')
a('            p.paragraph_format.space_before = Pt(0)')
a('            p.paragraph_format.space_after = Pt(0)')
a('            p.paragraph_format.line_spacing = LINE_SPACING')
a('            p.paragraph_format.left_indent = Cm(0)')
a('            safe = item["txt"].replace("\\t", "    ")')
a('            run = p.add_run(safe)')
a('            run.font.name = "Courier New"')
a('            run._element.rPr.rFonts.set(qn("w:eastAsia"), "SimSun")')
a('            run.font.size = LINE_FONT_SIZE')
a('    doc.save(str(OUTPUT_PATH))')
a('    return len(all_pages)')
a('')
a('')
a('def main():')
a('    print("=" * 60)')
a('    print("generating copyright doc...")')
a('    print("software:", SOFTWARE_NAME)')
a('    print("=" * 60)')
a('    bl = collect(BACKEND_FILES)')
a('    fl = collect(FRONTEND_FILES)')
a('    print("backend lines:", len(bl))')
a('    print("frontend lines:", len(fl))')
a('    print("total lines:", len(bl) + len(fl))')
a('    bp = split_pages(bl, 30)')
a('    fp = split_pages(fl, 30)')
a('    print("backend pages:", len(bp))')
a('    print("frontend pages:", len(fp))')
a('    total = make_doc(bp, fp)')
a('    print("saved:", OUTPUT_PATH)')
a('    print("total pages:", total)')
a('    ok = True')
a('    for i, pg in enumerate(bp + fp, 1):')
a('        if len(pg) < LINES_PER_PAGE:')
a('            print("WARN: page", i, "only", len(pg), "lines")')
a('            ok = False')
a('    if total > MAX_TOTAL_PAGES:')
a('        print("WARN: too many pages")')
a('        ok = False')
a('    if ok:')
a('        print("OK: all requirements met")')
a('')
a('')
a('if __name__ == "__main__":')
a('    main()')
a('')

with open("generate_lab_copyright_doc.py", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("bootstrap done, script written")
