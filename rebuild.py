import zipfile, os

src_dir = r'target/extracted-lib'
out_jar = r'target/ict-platform-1.0.0.jar'
loader_dir = r'target/loader-extract'

with zipfile.ZipFile(out_jar, 'w', zipfile.ZIP_DEFLATED) as zout:
    # loader classes at root
    if os.path.isdir(loader_dir):
        for root, dirs, files in os.walk(loader_dir):
            for f in files:
                if f.endswith('.class'):
                    fp = os.path.join(root, f)
                    rel = os.path.relpath(fp, loader_dir)
                    zout.write(fp, rel, compress_type=zipfile.ZIP_STORED)
        print('loader classes added')

    # BOOT-INF
    for root, dirs, files in os.walk(os.path.join(src_dir, 'BOOT-INF')):
        for f in files:
            fp = os.path.join(root, f)
            rel = os.path.relpath(fp, src_dir)
            if rel.startswith('BOOT-INF/lib'):
                zout.write(fp, rel, compress_type=zipfile.ZIP_STORED)
            else:
                zout.write(fp, rel, compress_type=zipfile.ZIP_DEFLATED)
        for d in dirs:
            dp = os.path.join(root, d)
            rel_d = os.path.relpath(dp, src_dir) + '/'
            zi = zipfile.ZipInfo(rel_d)
            zi.external_attr = 0x10
            zout.writestr(zi, b'')

    # META-INF
    for root, dirs, files in os.walk(os.path.join(src_dir, 'META-INF')):
        for f in files:
            fp = os.path.join(root, f)
            rel = os.path.relpath(fp, src_dir)
            zout.write(fp, rel, compress_type=zipfile.ZIP_DEFLATED)

    # static
    for root, dirs, files in os.walk(os.path.join(src_dir, 'static')):
        for f in files:
            fp = os.path.join(root, f)
            rel = os.path.relpath(fp, src_dir)
            zout.write(fp, rel, compress_type=zipfile.ZIP_DEFLATED)

print('jar built:', os.path.getsize(out_jar), 'bytes')
