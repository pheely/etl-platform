# Grant User Viewer Role

Organization viewer

```bash
 gcloud organizations add-iam-policy-binding 173975961793 \
 --member "user:host01@pycloudlabs.cc" \
 --role roles/resourcemanager.organizationViewer
 
 gcloud organizations add-iam-policy-binding 173975961793 \
 --member "user:service01@pycloudlabs.cc" \
 --role roles/resourcemanager.organizationViewer
```

Folder viewer

```bash
gcloud organizations add-iam-policy-binding 173975961793 \
--member "user:service01@pycloudlabs.cc" \
--role roles/resourcemanager.folderViewer

gcloud organizations add-iam-policy-binding 173975961793 \
--member "user:host01@pycloudlabs.cc" \
--role roles/resourcemanager.folderViewer
```

Project viewer

```bash
gcloud projects add-iam-policy-binding py-host-01 \
--member "user:host01@pycloudlabs.cc" --role roles/viewer

gcloud projects add-iam-policy-binding py-service-01 \
--member "user:service01@pycloudlabs.cc" --role roles/viewer
```