require 'ansimate'

module Ansimate
  class CLI
    attr_accessor :fg_colors, :bg_colors
    attr_accessor :default_fg, :default_bg
    attr_writer :current_fg, :current_bg
    attr_accessor :reversed, :bold, :underlined

    def initialize *args
      self.default_fg = 'white'
      self.default_bg = 'black'
      reset

      self.fg_colors = {
        30 => 'black',
        31 => 'red',
        32 => 'green',
        33 => 'yellow',
        34 => 'blue',
        35 => 'magenta',
        36 => 'cyan',
        37 => 'white',
        39 => default_fg
      }

      self.bg_colors = {
        40 => 'black',
        41 => 'red',
        42 => 'green',
        43 => 'yellow',
        44 => 'blue',
        45 => 'magenta',
        46 => 'cyan',
        47 => 'white',
        49 => default_bg
      }
    end

    def reset
      self.current_fg = self.default_fg
      self.current_bg = self.default_bg
      self.bold = self.reversed = self.underlined = false
    end

    def decipher ansi_codes
      ansi_codes.to_s.split(";").map(&:to_i).each do |ansi_code|
        process_code(ansi_code)
      end
    end

    def current_fg
      reversed ? @current_bg : @current_fg
    end

    def current_bg
      reversed ? @current_fg : @current_bg
    end

    def process_code ansi_code
      case ansi_code
        when 0
          reset
        when 1
          bold = true
        when 4,24
          self.underlined = ansi_code == 4
        when 7,27
          self.reversed = ansi_code == 7
        else
          @current_fg = self.fg_colors[ansi_code] || @current_fg
          @current_bg = self.bg_colors[ansi_code] || @current_bg
      end
    end

    def style_attributes
      fx = []
      fx << 'text-decoration: underline' if self.underlined
      fx << 'font-weight: bold' if self.bold
      fx << "color: #{self.current_fg}"
      fx << "background-color: #{self.current_bg}"
      fx.join(';')
    end

    def execute
      body_content = ''

      STDIN.readlines.each do |line|
        line.split("\e").each do |lp|
          lp.slice!(%r{(\[((\d+(;\d+)*))?m)})
          reset if $1 && !$2
          decipher($3)
          body_content << %{<span style="#{self.style_attributes}">#{lp.chomp}</span>}
        end
        body_content << "<br/>"
      end

      html = <<-HTML
        <?xml version="1.0" encoding="UTF-8" ?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
          <head>
            <meta http-equiv="Content-Type" content="application/xml+xhtml; charset=UTF-8" />
            <title>output</title>
          </head>
          <body style="background-color: #{default_bg}; color: #{default_fg}; font-family: Monaco">
            #{body_content}
          </body>
        </html>
      HTML
      puts html
    end
  end
end
