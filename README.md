![License-Type](https://shields.io/github/license/vinalti/Home-Certificate-Generator) &nbsp;
![Code-Size](https://shields.io/github/languages/code-size/vinalti/Home-Certificate-Generator) &nbsp;
![Open-Issues](https://shields.io/github/issues-raw/vinalti/Home-Certificate-Generator) &nbsp;
![Language](https://img.shields.io/badge/Language-Bash-blue) &nbsp;
<!-- ![Downloads](https://shields.io/github/downloads/vinalti/Home-Certificate-Generator/total) -->
# Trusted Self-Signed SSL Certificates Generator
## Description
Easy to use, this script allows you to generate self-signed certificates that can be trusted 
thanks to the CA. This is entirely offline, no certificate authority is required.

The script `generate_certificate.sh` will generate a private key (or use an existing one) and
allows you to generate **trusted self-signed certificates** for your home or company network.

This script is a wrapper around the `openssl` command.
It allows anyone to generate a RootCA, and issue certificates for home
servers to be trusted.

It is a very painful process to do manually, where you very often endup with a certificate
which look valid but is reported invalid for some obscure reasons. This script automatize
this process and provide you with valid certificates, perfect for any local server such as
Home Assistant, Pi-Hole, Proxmox, Local GitLab, etc.

> **Warning**  
> You will need to trust the Root CA on every client that will be connecting.  This is easy
> to do at home or in small company network. However **the certificates will not work for an
> online service.**  
> Find more informations [below](#trust-the-certificates).

## Usage

```yaml
USAGE: generate_certificate.sh [-h] [-f] [-C <cert>] [-K <key>]
```
**Options:**
```yaml
    -h          Display help
    -f          Force overwrite certificate if it exists
    -K <key>    Use <key> as CA private key 
    -C <cert>   Use <cert> as CA public certificate
    -d <days>   Set new certificate life duration to <days>
  ```

> **Note**  
> It is better to use `-C` and `-K` together as a private key should always be linked with its public key.  
> If the public key is not mentionned it will be re-generated. If the private key is not mentionned, both keys will be regenerated.

## Getting Started
Here is the simplest workflow you may want to follow to get started.

> **Note**  
> Steps 3 and 4 are skipped if the Root CA already exists.

  1. Download this project locally
  2. Execute `bash generate_certificate.sh` (see above or `-h` for more options)  
  3. [🔄3x] Enter a new password for Root CA Private Key (later referred as: 'CA Password')  
  4. Fill in the details of the RootCA (most are optional)  
  5. Enter new Certificate ID (recommended to use the local domain name as cert name, e.g: `mydomain.local`)  
  6. Enter Certificate life duration in days (You may skip with step with the `-d <days>` option.)  
  7. Enter alternative names one after the other (examples: `DNS:mydomain.local`, `DNS:*.mydomain.local` or `IP:192.168.1.1`).  
     When you are done, press `ENTER`  
  8. Press `ENTER` to validate the displayed alternative name or edit the configuration manually if required.
  9. Enter CA Password (from step 3)  
  10. Press `ENTER` to start another certificate (➡ step 5) or `CTRL`+`C` to Stop here.  

## Importing Certificate on Server (Private key)
Refer to the documentation of the device or service you are setting up.  
Be aware: some service will ask only for a private and public key, and some will ask for the root CA in addition.
  1. If you are prompted only for private and public key:
     - Upload the `./<id>/<id>.priv.key` as private key
     - Upload the `./<id>/<id>.chain.pem` as public certificate chain
  2. If you are also prompted for the Root CA in addition to the private and public key:
     - Upload the `./<id>/<id>.priv.key` as private key
     - Upload the `./<id>/<id>.pub.pem` as public key
     - Upload the `./CA/CA.pem` as Root CA

Those indications are general and may not be accurate to your specific need.

## Trust the Certificates
In order to trust the certificates you generated you will have to import the public CA directly on your devices.  
The default file path for the public CA when generated is `./CA/CA.pem`  
Please make sure you copied the CA on the device as a first step.  
Note that the extension `.pem` may be replaced by `.crt` without modifying the content of the file.

### Debian & Debian-Based (Ubuntu, ...)
1. Move the CA certificate (`ca.pem`) into `/usr/local/share/ca-certificates/ca.crt`.
2. Update the Cert Store with:
    ```bash
    sudo update-ca-certificates
    ```
See documentation [here](https://wiki.debian.org/Self-Signed_Certificate) and [here.](https://manpages.debian.org/buster/ca-certificates/update-ca-certificates.8.en.html)

### Fedora
1. Move the CA certificate (`ca.pem`) to `/etc/pki/ca-trust/source/anchors/ca.pem` or `/usr/share/pki/ca-trust-source/anchors/ca.pem`
2. Now run as root / with `sudo`:
```bash
update-ca-trust
```
See documentation [here.](https://docs.fedoraproject.org/en-US/quick-docs/using-shared-system-certificates/)

### Arch-Linux
System-wide – Arch(p11-kit)
(From arch wiki)
1. Run (As root)
    ```bash
    trust anchor --store myCA.crt
    ```
- The certificate will be written to `/etc/ca-certificates/trust-source/myCA.p11-kit` and the "legacy" directories automatically updated.
- If you get "no configured writable location" or a similar error, import the CA manually:
    - Copy the certificate to the /etc/ca-certificates/trust-source/anchors directory.
    - and then
        ```bash 
        update-ca-trust
        ```
See documentation [here](https://wiki.archlinux.org/title/User:Grawity/Adding_a_trusted_CA_certificate)

### Windows

1. Assuming the path to your generated CA certificate as `C:\ca.pem`, run:
    ```powershell
    Import-Certificate -FilePath "C:\ca.pem" -CertStoreLocation Cert:\LocalMachine\Root
    ```
    > **Note**  
    > Set `-CertStoreLocation` to `Cert:\CurrentUser\Root` in case you want to trust certificates only for the logged in user.

OR

1. In Command Prompt, run:
    ```sh
    certutil.exe -addstore root C:\ca.pem
    ```
    _`certutil.exe` is a built-in tool (classic `System32` one) and adds a system-wide trust anchor._

### Android

The steps may vary from device / OS version but that should be looking like that:
1. Open Phone Settings
2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
3. Choose `Install a certificate`
4. Choose `CA Certificate`
5. Locate the certificate file `ca.pem` on your SD Card/Internal Storage using the file manager.
6. Select to load it.
7. Done!

## Attributions
 - Inspired by [Christian Lempa CheatSheet](https://github.com/ChristianLempa/cheat-sheets) about [SSL Certificate](https://github.com/ChristianLempa/cheat-sheets/blob/main/misc/ssl-certs.md)
 - `openssl` is a command line tool from the [OpenSSL Project](https://github.com/openssl/openssl)
