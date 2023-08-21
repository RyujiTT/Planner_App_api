require "test_helper"

class UserTest < ActiveSupport::TestCase

  def active_user
    User.find_by(activated: true)
  end

  test "name_validation" do
    # 入力必須
    user = User.new(email: "test@example.com", password: "password")
    user.save
    required_msg = ["名前 を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)  # 追加

    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    maxlength_msg = ["名前 は30文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    name = "あ" * max
    user.name = name
    assert_difference("User.count", 1) do
      user.save
    end
  end


  test "email_validation" do
    # 入力必須
    user = User.new(name: "test", password: "password")
    user.save
    required_msg = ["メールアドレス を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 文字数制限
    max = 255
    domain = "@example.com"
    email = "a" * ((max + 1) - domain.length) + domain
    assert max < email.length

    user.email = email
    user.save
    maxlength_msg = ["メールアドレス は255文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック format = /\A\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/
    ok_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    ok_emails.each do |email|
      user.email = email
      assert user.save
    end

    ng_emails = %w(
      aaa
      a.ex.com
      メール@ex.com
      a~a@ex.com
      a@|.com
      a@ex.
      .a@ex.com
      a＠ex.com
      Ａ@ex.com
      a@?,com
      １@ex.com
      "a"@ex.com
      a@ex@co.jp
    )
    ng_emails.each do |email|
      user.email = email
      user.save
      format_msg = ["メールアドレス は不正な値です"]
      assert_equal(format_msg, user.errors.full_messages)
    end
  end


  test "email_downcase" do
    # email小文字化テスト
    email = "USER@EXAMPLE.COM"
    user = User.new(email: email)
    user.save
    assert user.email == email.downcase
  end

  test "active_user_uniqueness" do
    email = "test@example.com"

    # アクティブユーザーがいない場合、同じメールアドレスが登録できているか
    count = 3
    assert_difference("User.count", count) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end

    # ユーザーがアクティブになった場合、バリデーションエラーを吐いているか
    active_user = User.find_by(email: email)
    active_user.update!(activated: true)
    assert active_user.activated

    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      uniqueness_msg = ["メールアドレス はすでに存在します"]
      assert_equal(uniqueness_msg, user.errors.full_messages)
    end

    # アクティブユーザーがいなくなった場合、ユーザーは保存できているか
    active_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password", activated: true)
    end

    # 一意性は保たれているか
    assert_equal(1, User.where(email: email, activated: true).count)
  end

  test "password_validation" do
    # 入力必須
    user = User.new(name: "test", email: "test@example.com")
    user.save
    required_msg = ["パスワード を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # min文字以上
    min = 8
    user.password = "a" * (min - 1)
    user.save
    minlength_msg = ["パスワード は8文字以上で入力してください"]
    assert_equal(minlength_msg, user.errors.full_messages)

    # max文字以下
    max = 72
    user.password = "a" * (max + 1)
    user.save
    maxlength_msg = ["パスワード は72文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    ok_passwords = %w(
      pass---word
      ________
      12341234
      ____pass
      pass----
      PASSWORD
    )
    ok_passwords.each do |pass|
      user.password = pass
      assert user.save
    end

    ng_passwords = %w(
      pass/word
      pass.word
      |~=?+"a"
      １２３４５６７８
      ＡＢＣＤＥＦＧＨ
      password@
    )
    format_msg = ["パスワード は半角英数字・ハイフン・エンダーバーが使えます"]
    ng_passwords.each do |pass|
      user.password = pass
      user.save
      assert_equal(format_msg, user.errors.full_messages)
    end
  end
end
