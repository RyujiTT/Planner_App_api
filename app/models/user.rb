require "validator/email_validator"

class User < ApplicationRecord
  # Token生成モジュール
  include TokenGenerateService

  before_validation :downcase_email
  # bcrypt
  has_secure_password

  # validates
  validates :name, presence: true, 
                   length: {
                    maximum: 30, 
                    allow_blank: true 
                  }

  validates :email, presence: true,
                    email: { allow_blank: true }

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

  ## methods
  # class method  ###########################
  class << self
    # emailからアクティブなユーザーを返す
    def find_by_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # class method end #########################

  # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_by_activated(email).present?
  end

  # リフレッシュトークンのJWT IDを記憶する
  def remember(jti)
    update!(refresh_jti: jti)
  end

  # リフレッシュトークンのJWT IDを削除する
  def forget
    update!(refresh_jti: nil)
  end 

  def response_json(payload = {})
    as_json(only: [:id, :name]).merge(payload).with_indifferent_access
  end

  private

    # email小文字化
    def downcase_email
      self.email.downcase! if email
    end

end
