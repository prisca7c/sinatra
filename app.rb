require 'date'

class InteractiveCalendar
  def initialize
    @current_date = Date.today
    @selected_date = @current_date
    @events = Hash.new { |hash, key| hash[key] = [] }
  end

  def display_calendar
    puts "\n#{@current_date.strftime("%B %Y")}"
    puts "Mo Tu We Th Fr Sa Su"
    
    first_day_of_month = Date.new(@current_date.year, @current_date.month, 1)
    last_day_of_month = Date.new(@current_date.year, @current_date.month, -1)
    days_in_month = (first_day_of_month..last_day_of_month).to_a

    days_in_month.each do |day|
      print day.day.to_s.rjust(2)
      print " "

      if day.wday == 6 || day == last_day_of_month
        puts ""
      end
    end

    puts ""
  end

  def display_events
    events_for_month = @events[@current_date.strftime("%B %Y")]
    puts "\nEvents for #{@current_date.strftime("%B %Y")}:"
    events_for_month.each do |event|
      puts "- #{event}"
    end
  end

  def add_event
    puts "Enter event for #{@selected_date.strftime("%B %d, %Y")}:"
    event = gets.chomp
    @events[@selected_date.strftime("%B %Y")] << "#{@selected_date.day}: #{event}"
    puts "Event added successfully!"
  end

  def run
    loop do
      display_calendar
      display_events

      puts "\nOptions:"
      puts "1. Move to the next month"
      puts "2. Move to the previous month"
      puts "3. Add event for the selected date"
      puts "4. Exit"

      choice = gets.chomp.to_i

      case choice
      when 1
        @current_date = @current_date.next_month
      when 2
        @current_date = @current_date.prev_month
      when 3
        add_event
      when 4
        break
      else
        puts "Invalid choice. Please try again."
      end
    end

    puts "Exiting. Goodbye!"
  end
end

# Example usage
calendar = InteractiveCalendar.new
calendar.run
