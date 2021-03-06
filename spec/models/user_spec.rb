require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :first_name => "Justin",
              :last_name => "Vanderheide",
              :email => "user@example.com",
              :password => "foobar",
              :password_confirmation => "foobar"}
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a first name" do
    no_name_user = User.new(@attr.merge(:first_name => ""))
    no_name_user.should_not be_valid
  end

  it "should require a last name" do
    no_name_user = User.new(@attr.merge(:last_name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  describe "Email validations" do

    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end

    it "should reject duplicate email addresses" do
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end

    it "should reject identical email addresses including case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  end

  describe "Password validation" do

    it "should require a password" do
      no_password_user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      no_password_user.should_not be_valid
    end

    it "should require a matching password confirmation" do
      bad_confirmation_user = User.new(@attr.merge(:password_confirmation => "Invalid"))
      bad_confirmation_user.should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      short_password_user = User.new(@attr.merge(:password => short,
                                                 :Password_confirmation => short))
      short_password_user.should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      long_password_user = User.new(@attr.merge(:password => long,
                                                :password_confirmation => long))
      long_password_user.should_not be_valid
    end
  end

  describe "Password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "Should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "shift attributes" do

    before(:each) do
      @user = User.create!(@attr)
      @user.toggle!(:primary)
      @shifttype = Factory(:shift_type)
      @shift_secondary = Factory(:shift, :secondary => @user, :start => DateTime.now - 5.days)
      @shift_primary = Factory(:shift, :primary => @user, :start => DateTime.now - 4.days)
      @shift_neither = Factory(:shift, :start => DateTime.now - 3.days)
    end

    it "should have a shifts attribute" do
      @user.should respond_to(:shifts)
    end

    it "should contain taken secondary shifts" do
      @user.shifts.should include(@shift_secondary)
    end

    it "should contain taken primary shifts" do
      @user.shifts.should include(@shift_primary)
    end

    it "should not include shifts that don't belong to the user" do
      @user.shifts.should_not include(@shift_neither)
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "primary attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to primary" do
      @user.should respond_to(:primary)
    end

    it "should not be a primary by default" do
      @user.should_not be_primary
    end

    it "should be convertible to a primary" do
      @user.toggle!(:primary)
      @user.should be_primary
    end
  end
end
