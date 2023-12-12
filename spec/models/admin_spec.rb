require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe "device.gem のバリデーション検証" do
    it "メールアドレス,パスワードがあれば有効であること" do
      admin = Admin.new(
        email: "tester@example.com",
        password: "dottle-nouveau-pavilion-tights-furze",
      )
      expect(admin).to be_valid
    end

    it "emailがなければ無効であること" do
      admin = Admin.new(
        email: nil,
        password: "dottle-nouveau-pavilion-tights-furze",
      )
      expect(admin).to_not be_valid
    end

    it "passwordがなければ無効であること" do
      admin = Admin.new(
        email: "tester@example.com",
        password: nil,
      )
      expect(admin).to_not be_valid
    end

    it "重複したメールアドレスは許可されないこと" do
      Admin.create(
        email: "tester@example.com",
        password: "dottle-nouveau-pavilion-tights-furze",
      )
      admin = Admin.new(
        email: "tester@example.com",
        password: "12345678qwertyui",
      )
      expect(admin).to_not be_valid
    end
  end
end
