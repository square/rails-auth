# frozen_string_literal: true

require "certificate_authority"
require "fileutils"

cert_path = File.expand_path("../../tmp/certs", __dir__)
FileUtils.mkdir_p(cert_path)

#
# Create CA certificate
#

ca = CertificateAuthority::Certificate.new

ca.subject.common_name  = "cacertificate.com"
ca.serial_number.number = 1
ca.key_material.generate_key
ca.signing_entity = true

ca.sign! "extensions" => { "keyUsage" => { "usage" => %w[critical keyCertSign] } }

ca_cert_path = File.join(cert_path, "ca.crt")
ca_key_path  = File.join(cert_path, "ca.key")

File.write ca_cert_path, ca.to_pem
File.write ca_key_path,  ca.key_material.private_key.to_pem

#
# Valid client certificate
#

valid_cert = CertificateAuthority::Certificate.new
valid_cert.subject.common_name = "127.0.0.1"
valid_cert.subject.organizational_unit = "ponycopter"
valid_cert.serial_number.number = 2
valid_cert.key_material.generate_key
valid_cert.parent = ca
valid_cert.sign!

valid_cert_path = File.join(cert_path, "valid.crt")
valid_key_path  = File.join(cert_path, "valid.key")

File.write valid_cert_path, valid_cert.to_pem
File.write valid_key_path,  valid_cert.key_material.private_key.to_pem

#
# Valid client certificate with extensions
#

valid_cert_with_ext = CertificateAuthority::Certificate.new
valid_cert_with_ext.subject.common_name = "127.0.0.1"
valid_cert_with_ext.subject.organizational_unit = "ponycopter"
valid_cert_with_ext.serial_number.number = 3
valid_cert_with_ext.key_material.generate_key
signing_profile = {
  "extensions" => {
    "basicConstraints" => {
      "ca" => false
    },
    "crlDistributionPoints" => {
      "uri" => "http://notme.com/other.crl"
    },
    "subjectKeyIdentifier" => {},
    "authorityKeyIdentifier" => {},
    "authorityInfoAccess" => {
      "ocsp" => %w[http://youFillThisOut/ocsp/]
    },
    "keyUsage" => {
      "usage" => %w[digitalSignature keyEncipherment dataEncipherment]
    },
    "extendedKeyUsage" => {
      "usage" => %w[serverAuth clientAuth]
    },
    "subjectAltName" => {
      "uris" => %w[spiffe://example.com/exemplar https://www.example.com/page1 https://www.example.com/page2],
      "ips" => %w[0.0.0.0 127.0.0.1 192.168.1.1],
      "dns_names" => %w[example.com exemplar.com somethingelse.com]
    },
    "certificatePolicies" => {
      "policy_identifier" => "1.3.5.8",
      "cps_uris" => %w[http://my.host.name/ http://my.your.name/],
      "user_notice" => {
        "explicit_text" => "Explicit Text Here",
        "organization" => "Organization name",
        "notice_numbers" => "1,2,3,4"
      }
    }
  }
}
valid_cert_with_ext.parent = ca
valid_cert_with_ext.sign!(signing_profile)

valid_cert_with_ext_path = File.join(cert_path, "valid_with_ext.crt")
valid_key_with_ext_path  = File.join(cert_path, "valid_with_ext.key")

File.write valid_cert_with_ext_path, valid_cert_with_ext.to_pem
File.write valid_key_with_ext_path,  valid_cert_with_ext.key_material.private_key.to_pem
