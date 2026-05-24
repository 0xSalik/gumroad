# frozen_string_literal: true

class DominicanRepublicBankAccount < BankAccount
  BANK_ACCOUNT_TYPE = "DO"

  # Stripe's DR routing directory expects a 3-digit zero-padded bank code
  # (e.g. `003` for Banco Popular Dominicano, `021` for Banesco).
  # Shorter inputs (`2`, `21`) are rejected by Stripe with a confusing
  # "must contain both the bank code and the branch code" format error,
  # and longer inputs / SWIFT/BIC codes are rejected as not in the directory.
  BANK_CODE_FORMAT_REGEX = /^\d{3}$/
  ACCOUNT_NUMBER_FORMAT_REGEX = /^\d{1,28}$/
  private_constant :BANK_CODE_FORMAT_REGEX, :ACCOUNT_NUMBER_FORMAT_REGEX

  alias_attribute :bank_code, :bank_number

  validate :validate_bank_code
  validate :validate_account_number

  validates :bank_code, presence: true
  validates :account_number, presence: true

  def routing_number
    bank_code
  end

  def bank_account_type
    BANK_ACCOUNT_TYPE
  end

  def country
    Compliance::Countries::DOM.alpha2
  end

  def currency
    Currency::DOP
  end

  def account_number_visual
    "******#{account_number_last_four}"
  end

  def to_hash
    {
      routing_number:,
      account_number: account_number_visual,
      bank_account_type:
    }
  end

  private
    def validate_bank_code
      return if BANK_CODE_FORMAT_REGEX.match?(bank_code)
      errors.add :base, "The bank code is invalid."
    end

    def validate_account_number
      return if ACCOUNT_NUMBER_FORMAT_REGEX.match?(account_number_decrypted)
      errors.add :base, "The account number is invalid."
    end
end
