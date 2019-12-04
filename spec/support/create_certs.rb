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
# Create evil MitM self-signed certificate
#

self_signed_cert = CertificateAuthority::Certificate.new
self_signed_cert.subject.common_name = "127.0.0.1"
self_signed_cert.subject.organizational_unit = "ponycopter"
self_signed_cert.serial_number.number = 2
self_signed_cert.key_material.generate_key
self_signed_cert.sign!

self_signed_cert_path = File.join(cert_path, "invalid.crt")
self_signed_key_path  = File.join(cert_path, "invalid.key")

File.write self_signed_cert_path, self_signed_cert.to_pem
File.write self_signed_key_path,  self_signed_cert.key_material.private_key.to_pem
