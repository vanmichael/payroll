require 'pry'
require 'csv'

class EmployeeReader

	def initialize(file_name)
		get_employees(file_name)
	end

	def get_employees(file_name)
		@employees = []
		CSV.foreach(file_name, headers: true) do |row|
			case row["salary_type"]
			when "commission" then @employees << CommissionSalesPerson.new(row["first_name"],row["last_name"],row["base_salary"],row["commission"])
			when "quota" then @employees << QuotaSalesPerson.new(row["first_name"],row["last_name"],row["base_salary"],row["bonus"],row["sales_quota"])
			when "owner" then @employees << Owner.new(row["first_name"],row["last_name"],row["base_salary"],row["bonus"],row["company_quota"])
			else @employees << Employee.new(row["first_name"],row["last_name"],row["base_salary"])
			end
		end
		@employees
	end
end

class Employee
	attr_reader :first_name, :last_name, :base_salary

	def initialize(first_name,last_name, base_salary)
		@first_name = first_name
		@last_name = last_name
		@base_salary = base_salary.to_f
		display_amount_owed
	end

	def net_pay_per_month
		0.70 * gross_salary_per_month
	end

	def gross_salary_per_month
		(@base_salary.to_f/12).to_f
	end

	def display_amount_owed
		puts "#{first_name} #{last_name}"
		puts gross_salary_per_month
		puts net_pay_per_month
	end
end

class Owner < Employee

	def initialize(first_name, last_name, base_salary, bonus, company_quota)
		super(first_name,last_name,base_salary)
		@bonus = bonus.to_f
		@company_quota = company_quota.to_f
		get_sales
		net_pay_per_month
	end

	def get_sales
		@total_sales = 0
		employee_sales = Sale.new('sales.csv').gross_sale_values
		employee_sales.each do |sale|
			@total_sales += sale.values.join.to_f
		end
	end

	def gross_salary_per_month
		if @total_sales.to_f >= @company_quota.to_f
			(@base_salary.to_f/12).to_f + (@bonus.to_f/12)
		else
			(@base_salary.to_f/12).to_f
		end
	end
end

class CommissionSalesPerson < Employee

	def initialize(first_name, last_name, base_salary, commission)
		super(first_name,last_name,base_salary)
		@commission = commission.to_f
		get_sales(last_name)
	end

	def get_sales(last_name)
		@total_sales = 0
		employee_sales = Sale.new('sales.csv').gross_sale_values
		employee_sales.each do |sale|
			@total_sales += sale.values.join.to_f if sale.keys.join == last_name
		end
	end

	def find_bonus
		@total_sales.to_f * @commission.to_f
	end	

	def gross_salary_per_month
		(@base_salary.to_f/12).to_f + (find_bonus/12)
	end
end

class QuotaSalesPerson < Employee

	def initialize(first_name, last_name, base_salary, bonus, sales_quota)
		super(first_name, last_name, base_salary)
		@sales_quota = sales_quota.to_f
		@bonus = bonus.to_f
		get_sales(last_name)
	end

	def get_sales(last_name)
		@total_sales = 0
		employee_sales = Sale.new('sales.csv').gross_sale_values
		employee_sales.each do |sale|
			@total_sales += sale.values.join.to_f if sale.keys.join == last_name
		end
	end

	def gross_salary_per_month	
		binding.pry
		if @total_sales == @sales_quota
			(@base_salary.to_f/12) + (@bonus/12)
		else
			@base_salary.to_f/12
		end
	end
end

class Sale

	attr_reader :gross_sale_values

	def initialize(file_name)
		get_sales(file_name)
	end

	def get_sales(file_name)
		@gross_sale_values = []
		CSV.foreach(file_name, headers: true) do |row|
			@gross_sale_values << Hash[row["last_name"],row["gross_sale_value"]]
		end
		@gross_sale_values
	end
end

EmployeeReader.new('employees.csv')
