# Home-Certificate-Generator
Allow you to automatically generate a trusted certificate for your home network. 

## Description
The script `generate_certificate.sh` will generate a private key (or use an existing one) 
and allow you to generate certificates for your home network.

This script is a simple wrapper around the `openssl` command.
It should allow anyone to generate a RootCA, and issue certificates for home
servers to be trusted 

## Usage

```yaml
USAGE: generate_certificate.sh [-h] [-f] [-C <cert>] [-K <key>]
```
**Options:**
```yaml
    -h          Display this help message
    -f          Overwrite certificate if it exists
    -K <key>    Use <key> as CA private key 
    -C <cert>   Use <cert> as CA public certificate
    -d <days>   Set new certificate duration to <days>
  ```
## Workflow
  1. Download this project locally
  2. Execute `bash generate_certificate.sh` (see above or `-h` for more options)  
  3. Enter 3x a new password for Root CA Private Key (later referred as: 'CA Password')  
  4. Fill in the details of the RootCA (most are optional)  
  5. Enter new Certificate ID (recommended to use the local domain name, e.g: `mydomain.local`)  
  6. Enter Certificate life duration (`365` for 1 year, `3650` for 10 years, ...)  
  7. Enter alternative names one after the other (examples: `DNS:mydomain.local`, `DNS:*.mydomain.local`, `IP:192.168.1.1`).  
     When you are done, press `ENTER`  
  8. Press `ENTER` to validate the displayed alternative name or edit the configuration manually if required.
  9. Enter CA Password  
  10. Press `ENTER` to start another certificate (step 5) or `CTRL`+`C` to Stop here.  

Note: It will skip steps 3 and 4 when the Root CA already exists.

## Attributions
 - Inspired by [Christian Lempa CheatSheet](https://github.com/ChristianLempa/cheat-sheets) about [SSL Certificate](https://github.com/ChristianLempa/cheat-sheets/blob/main/misc/ssl-certs.md)
 - `openssl` is a command line tool from the [OpenSSL Project](https://github.com/openssl/openssl)
