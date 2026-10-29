# JupyterLab – Notebook-Umgebung

Eine eigene JupyterLab-Instanz für jede Person eines Deployments, mit eigenem Speicher und eigenem Login. Die App läuft als Pods (`appstore.yaml`, App-Vertrag v2): **ein JupyterLab-Pod je Person** mit 5 GiB Speicher für Notebooks und Einstellungen, HTTPS-Link und eigenem Passwort unter „Meine Zugänge“.

## User-Management

Jede Person erhält ihren eigenen Pod und ein von der Plattform erzeugtes Passwort. Notebooks und Einstellungen liegen im persistenten Home-Verzeichnis und überstehen Pause/Fortsetzen und Neustart.

- **Login:** auf der Login-Seite das generierte Passwort eintragen („Password or token“).
- **Software:** JupyterLab, NumPy, pandas und Matplotlib (Versionen in `image/requirements.txt`). Weitere Pakete lassen sich im Notebook mit `%pip install …` nachinstallieren (braucht den Internetzugang, den die Lehrperson im Wizard einschaltet, TCP 80/443; sie landen im persistenten Home-Verzeichnis).
- **Kein `sudo`:** Systempakete (`apt`) können nicht installiert werden. Das Root-Dateisystem ist schreibgeschützt, schreibbar sind nur das Home-Verzeichnis und `/tmp`.

## Konfigurierbare Variablen

Keine. Kein File-Upload, alle Einstellungen stehen in `appstore.yaml`.

## Image und CI

`image/Dockerfile` wird von `.github/workflows/ci.yml` gebaut (zentrale Pipeline aus `app-registry`: Vertrag, hadolint, Smoke-Test, Trivy) und mit dem Sicherheitskontext der Plattform getestet (UID 1000, Read-only-Root, keine Capabilities; `.github/smoke-test.sh`).

- **Pull Request:** das Image wird gebaut und getestet, aber nicht veröffentlicht.
- **Push auf `main`:** das Image wird zusätzlich nach GHCR gepusht. Den Digest zeigt die Zusammenfassung des Jobs.
- Nach einer Änderung den neuen Digest in `appstore.yaml` eintragen und eine neue Version taggen. Die Plattform deployt nur Images, die per Digest festgelegt sind.

## Ältere Versionen

Die VM-Versionen (`v1.x`, JupyterHub mit Terraform und Packer) wurden aus dem Repository entfernt. Sie bleiben über ihre Git-Tags (z. B. `v1.0.0`) abrufbar.
