# Home-Certificate-Generator
## Description
The script `generate_certificate.sh` will generate a private key (or use an existing one) 
and allows you to generate **trusted certificates** for your home or company network.

This script is a wrapper around the `openssl` command.
It allows anyone to generate a RootCA, and issue certificates for home
servers to be trusted.

It is a very painful process to do manually, where you very often endup with a certificate
which look valid but is reported invalid for some obscure reasons. This script automatize
this process and provide you with valid certificates, perfect for any local server such as
Home Assistant, Pi-Hole, Proxmox, Local GitLab, etc.

Warning: You need to trust the Root CA on every client connecting. This is doable at home or
in small company network. However the certificates will not work for an online service.

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

Note: It is better to use `-C` and `-K` together as a private key should always be linked with its public key. If the public key is not mentionned it will be re-generated. If the private key is not mentionned, both keys will be regenerated.

## Getting Started
Here is the simplest workflow you may want to follow to get started.

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

Note: Steps 3 and 4 can be skipped if the Root CA already exists.

## Attributions
 - Inspired by [Christian Lempa CheatSheet](https://github.com/ChristianLempa/cheat-sheets) about [SSL Certificate](https://github.com/ChristianLempa/cheat-sheets/blob/main/misc/ssl-certs.md)
 - `openssl` is a command line tool from the [OpenSSL Project](https://github.com/openssl/openssl)
