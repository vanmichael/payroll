require './payroll.rb'

Sale.new('sales.csv')

EmployeeReader.new('employees.csv').employees.each do |employee|
	employee.display_amount_owed
end