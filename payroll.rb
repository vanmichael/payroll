require 'pry'
require 'csv'

class EmployeeReader
	attr_reader :employees

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
		binding.pry
	end

end

class Employee

	def initialize(first_name, last_name, base_salary)
		@first_name = first_name
		@last_name = last_name
		@base_salary = base_salary.to_f
	end

	def gross_salary_per_month
		(@base_salary.to_f/12).to_f
	end

	def net_pay_per_month
		0.70 * gross_salary_per_month
	end

	def display_amount_owed
		puts "                            "
		puts "***#{@first_name} #{@last_name}***"
		puts "Gross Salary: #{gross_salary_per_month.round(2)}"
		puts "Net Pay: #{net_pay_per_month.round(2)}"
	end

end

class Owner < Employee

	def initialize(first_name, last_name, base_salary, bonus, company_quota)
		super(first_name,last_name,base_salary)
		@bonus = bonus.to_f
		@company_quota = company_quota.to_f
		get_sales
	end

	def get_sales
		@total_sales = 0
		employee_sales = Sale.new('sales.csv').gross_sale_values
		employee_sales.each do |sale|
			@total_sales += sale.values.join.to_f
		end
	end

	def gross_salary_per_month
		if @total_sales >= @company_quota
			(@base_salary.to_f/12) + (@bonus)
		else
			(@base_salary.to_f/12)
		end
	end

	def net_pay_per_month
		super
	end

	def display_amount_owed
		puts "                            "
		puts "***#{@first_name} #{@last_name}***"
		puts "Gross Salary: #{gross_salary_per_month.round(2)}"
		puts "Net Pay: #{net_pay_per_month.round(2)}"
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

	def gross_salary_per_month
		(@base_salary/12) + ((@commission * @total_sales))
	end

	def net_pay_per_month
		super
	end

	def display_amount_owed
		puts "                            "
		puts "***#{@first_name} #{@last_name}***"
		puts "Gross Salary: #{gross_salary_per_month.round(2)}"
		puts "Commission: #{((@commission * @total_sales)*0.70).round(2)}"
		puts "Net Pay: #{net_pay_per_month.round(2)}"
	end
end

class QuotaSalesPerson < Employee

	def initialize(first_name, last_name, base_salary, bonus, sales_quota)
		super(first_name,last_name,base_salary)
		@bonus = bonus.to_f
		@sales_quota = sales_quota.to_f
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
		if @total_sales >= @sales_quota
			(@base_salary/12) + (@bonus)
		else
			@base_salary/12
		end
	end

	def net_pay_per_month
		super
	end

	def display_amount_owed
		puts "                            "
		puts "***#{@first_name} #{@last_name}***"
		puts "Gross Salary: #{gross_salary_per_month.round(2)}"
		puts "Net Pay: #{net_pay_per_month.round(2)}"
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
