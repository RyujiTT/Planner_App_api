class User < ApplicationRecord
  # bcrypt
  has_secure_password

  # validates
  validates :name, presence: true, 
                   length: {
                    maximum: 30, 
                    allow_blank: true 
                  }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  # \A     => 文字列の先頭にマッチ
  # [\w\-] => a-zA-Z0-9_-
  # +      => 1文字以上繰り返しているか
  # \z     => 文字列の末尾にマッチしているか
  validates :password, presence: true,
                      length: { minimum: 8 },
                      format: {
                        with: VALID_PASSWORD_REGEX,  # 書式チェック
                        message: :invalid_password,
                        allow_blank: true
                      },
                      allow_nil: true

end
