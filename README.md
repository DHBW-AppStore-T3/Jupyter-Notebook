# JupyterHub – Gemeinsame Notebook-Umgebung
 
Eine JupyterHub-Instanz auf einer gemeinsamen VM, die allen Teilnehmern eines Deployments individuelle JupyterLab-Sessions bereitstellt. Jeder Nutzer meldet sich mit persönlichen Zugangsdaten an und arbeitet in einer isolierten Notebook-Umgebung.
 
## User-Management
 
Jeder Nutzer erhält einen eigenen Linux-Account (abgeleitet aus der E-Mail-Adresse) und ein automatisch generiertes Passwort. JupyterHub nutzt PAM-Authentifizierung — der Login entspricht direkt dem Linux-Account. Alle Nutzer aller Teams teilen dieselbe VM, haben aber voneinander isolierte Home-Verzeichnisse und JupyterLab-Sessions. Zugangsdaten werden nach dem Deployment per Mail versendet.
 
## VM-Deployment
 
Es wird **eine gemeinsame VM** für alle Nutzer und alle Teams deployed — unabhängig von der Anzahl der Teams oder Nutzer. Die VM erhält eine öffentliche Floating IP und ist über Port `8000` erreichbar.
 
## Deployment-Dauer
 
| Phase | Dauer |

|---|---|

| Packer Image Build (einmalig) | ca. 10–15 Min |

| Terraform Apply | ca. 1–2 Min |

| VM-Boot + cloud-init (User-Anlage, JupyterHub-Start) | ca. 2–4 Min |

| **Gesamt erstmalig** | **ca. 15–22 Min** |
 
Bei vorhandenem Packer-Image entfällt der Build — dann ca. **3–6 Minuten** gesamt.
 
## Konfigurierbare Variablen
 
| Variable | Beschreibung | Pflicht |

|---|---|---|

| `network_uuid` | UUID des internen Netzwerks | Ja (Default vorhanden) |

| `floating_ip_pool` | Name des External Networks für die öffentliche IP | Ja (Default vorhanden) |

| `shared_secgroup_id` | ID der Security Group | Ja (Default vorhanden) |
 
Kein File-Upload. Alle Defaults sind auf die DHBW-OpenStack-Infrastruktur vorkonfiguriert und müssen in der Regel nicht geändert werden.

 

## Pod-Variante (ab v2.0.0)

Ab Version `v2.0.0` läuft Jupyter-Notebook als Pods statt als VM (`appstore.yaml`,
App-Vertrag v2): **ein JupyterLab-Pod je Person** mit eigenem Speicher (5 GiB für Notebooks
und Einstellungen), HTTPS-Link und eigenem Passwort unter „Meine Zugänge“. JupyterHub, SSH
und die gemeinsame VM entfallen; keine VM, kein Packer-Build, kein OpenStack-Credential.

- **Login:** auf der Login-Seite das generierte Passwort eintragen („Password or token“).
- **Software:** JupyterLab, NumPy, pandas und Matplotlib (Versionen in `image/requirements.txt`).
  Weitere Pakete lassen sich im Notebook mit `%pip install …` nachinstallieren (Internetzugang
  ist erlaubt; sie landen im persistenten Home-Verzeichnis).
- **Kein `sudo`:** Systempakete (`apt`) können nicht installiert werden; das Root-Dateisystem
  ist schreibgeschützt, schreibbar sind nur das Home-Verzeichnis und `/tmp`.
- **Image:** `image/Dockerfile` wird von `.github/workflows/image.yml` gebaut (inkl. Smoke-Test
  mit dem Sicherheitskontext der Plattform). Nach einer Änderung den neuen Digest in
  `appstore.yaml` eintragen und eine neue Version taggen.
- Die Versionen `v1.x` (Terraform/Packer) laufen unverändert weiter.
