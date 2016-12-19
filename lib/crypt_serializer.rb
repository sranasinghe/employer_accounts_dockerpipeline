require 'base64'

class CryptSerializer
  def load(cipher_text)
    return cipher_text if blank?(cipher_text)
    cipher_text = decode(cipher_text)
    decrypter = OpenSSL::Cipher::AES.new(256, :CBC).decrypt
    decrypter.key = decoded_key
    decrypter.iv = decoded_iv
    decrypter.update(cipher_text) + decrypter.final
  end

  def dump(plain_text)
    return plain_text if blank?(plain_text)
    encrypter = OpenSSL::Cipher::AES.new(256, :CBC).encrypt
    encrypter.key = decoded_key
    encrypter.iv = decoded_iv
    encrypted_binary_string = encrypter.update(plain_text.to_s.downcase) + encrypter.final
    encode(encrypted_binary_string)
  end

  def key
    ENV['BASE_64_ENCODED_CIPHER_KEY']
  end

  def iv
    ENV['BASE_64_ENCODED_CIPHER_IV']
  end

  private

  def decode(binary_text)
    Base64.decode64(binary_text)
  end

  def encode(text)
    Base64.encode64(text)
  end

  def decoded_key
    decode(key)
  end

  def decoded_iv
    decode(iv)
  end

  def blank?(text)
    text.to_s.empty?
  end
end
