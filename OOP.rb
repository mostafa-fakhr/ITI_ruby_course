require 'time'

# Logger Module
module Logger
  def log_info(message)
    log("info", message)
  end

  def log_warning(message)
    log("warning", message)
  end

  def log_error(message)
    log("error", message)
  end

  private

  def log(log_type, message)
    File.open("app.log", "a") do |file|
      file.puts "#{Time.now.to_s} -- #{log_type} -- #{message}"
    end
  end
end

# User class
class User
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

# Transaction class
class Transaction
  attr_reader :user, :value

  def initialize(user, value)
    @user = user
    @value = value
  end
end

# Abstract Bank class
class Bank
  def process_transactions(transactions, &callback)
    transaction_messages = transactions.map { |transaction| "User #{transaction.user.name} transaction with value #{transaction.value}" }.join(", ")
    log_info("Processing Transactions #{transaction_messages}...")

    transactions.each do |transaction|
      begin
        if transaction.user.nil? || !bank_users.include?(transaction.user)
          raise "User not exist in the bank"
        elsif transaction.user.balance + transaction.value < 0
          raise "Not enough balance"
        end
        log_info("User #{transaction.user.name} transaction with value #{transaction.value} succeeded")
        transaction.user.balance += transaction.value

        if transaction.user.balance.zero?
          log_warning("#{transaction.user.name} has 0 balance")
        end

       
        callback.call("success", transaction)
      rescue => e
        log_error("#{transaction.user.name} transaction with value #{transaction.value} failed with message #{e.message}")
        callback.call("failure", transaction)
      end
    end
  end

end

class CBABank < Bank
  include Logger

  def initialize(users)
    @bank_users = users
  end

  def bank_users
    @bank_users
  end
end

# Main
users = [
  User.new("Ali", 200),
  User.new("Peter", 500),
  User.new("Manda", 100)
]

out_side_bank_users = [
  User.new("Menna", 400),
]

transactions = [
  Transaction.new(users[0], -20),
  Transaction.new(users[0], -30),
  Transaction.new(users[0], -50),
  Transaction.new(users[0], -100),
  Transaction.new(users[0], -100),
  Transaction.new(out_side_bank_users[0], -100)
]

cba_bank = CBABank.new(users)
cba_bank.process_transactions(transactions) do |status, transaction|
  reason = if status == 'failure'
             transaction.user.nil? || !cba_bank.bank_users.include?(transaction.user) ? "#{transaction.user.name} not exist in the bank!!" : "Not enough balance"
           else
             nil
           end
  puts "Call endpoint for #{status} of #{transaction.user.name} transaction with value #{transaction.value} #{reason ? "with reason #{reason}" : ''}"
end
