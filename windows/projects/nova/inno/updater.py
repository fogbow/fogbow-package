from github import Github
import sys
import zipfile
import os
import tempfile
import requests
import shutil
import json

# Arguments list
# 0 - script name
# 1 - fogbow root directory

if len(sys.argv) < 2:
  sys.exit()

def get_tags():
    tags = None
    try:
        with open(os.path.join(fogbow_root_path, 'tags'), 'r') as tags_file:
            tags = json.load(tags_file)
    except:
        pass
    return tags

def set_tags():
    try:
        with open(os.path.join(fogbow_root_path, 'tags'), 'w') as tags_file:
            json.dump(current_tags, tags_file)
        return True
    except Exception:
        return False

def download_file(target_file, url):
    with open(target_file, 'wb') as handle:
        response = requests.get(url, stream=True)
        if not response.ok:
            return False

        for block in response.iter_content(1024):
            if not block:
                break
            handle.write(block)
        return True

def install_qemuwindriver(extracted_dir):
    qemuwin_dir = os.path.join(qemuwin_parent_path, 'qemuwin')
    if os.path.exists(qemuwin_dir):
        shutil.rmtree(qemuwin_dir)
    shutil.copytree(os.path.join(extracted_dir, 'qemuwin'), qemuwin_dir)
    shutil.rmtree(extracted_dir)


def install_fogbow_powernap(extracted_dir):
    os.chdir(extracted_dir)
    os.system('%s setup.py install' % (os.path.join(pybow_root, 'python.exe')))

def update_project(proj, last_tag):
    if last_tag == current_tags[proj['project_key']]:
        return
    tmp_zipfile = os.path.join(temp_path, '%s' % proj['tmp_zip_filename'])
    if not download_file(tmp_zipfile, tag.zipball_url):
        return
    
    os.system('schtasks /End /TN %s' % (proj['service_name']))
    with zipfile.ZipFile(tmp_zipfile, 'r') as zip:
        file_list = zip.namelist()
        tmp_extracted_dir = file_list[0].replace('/', '')
        zip.extractall(temp_path)
    proj['install'](os.path.join(temp_path, tmp_extracted_dir))
    current_tags[proj['project_key']] = last_tag
    os.system('schtasks /Run /TN %s' % (proj['service_name']))

temp_path = tempfile.gettempdir()
fogbow_root_path = sys.argv[1]
pybow_root = os.path.join(fogbow_root_path, 'Pybow27')
qemuwin_parent_path = os.path.join(pybow_root, 'Lib', 'site-packages', 'nova', 'virt')

global current_tags
current_tags = get_tags()
projects = [{'repository': 'fogbow/nova-qemu-win-driver', 'project_key': 'nova-qemu-win-driver', 
             'tmp_zip_filename': 'qemuwindriver.zip', 'install': install_qemuwindriver, 
             'service_name': 'NovaComputeStarter'},
            {'repository': 'fogbow/fogbow-powernap-win32','project_key': 'fogbow-powernap-win32', 
             'tmp_zip_filename': 'fogbowpowernap.zip', 'install': install_fogbow_powernap, 
             'service_name': 'PowernapStarter'}]

gh = Github()
for proj in projects:
    try:
        repo = gh.get_repo(proj['repository'])
        repository_tags = list(repo.get_tags())
        if len(repository_tags) == 0:
            continue
        tag = repository_tags[0]
        update_project(proj, tag.name)
    except:
        pass
set_tags()
