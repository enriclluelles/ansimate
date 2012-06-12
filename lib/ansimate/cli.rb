require 'ansimate'

module Ansimate
  class CLI
    attr_accessor :effects, :fg_colors, :bg_colors
    attr_accessor :default_effect, :default_fg, :default_bg

    def initialize *args
      self.default_fg = 'white'
      self.default_bg = 'black'

      self.effects = {

      }

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

    def decipher escape_codes, fg_color, bg_color, effects
      escape_codes.to_s.split(";").map(&:to_i).each do |ansi_code|
        fg_color = self.fg_colors[ansi_code] || fg_color
        bg_color = self.bg_colors[ansi_code] || bg_color
      end
      return fg_color, bg_color, effects
    end

    def execute
      effects = self.default_effect
      fg_color = self.default_fg
      bg_color = self.default_bg

      body_content = ''

      STDIN.readlines.each do |line|
        line.split("\e").each do |lp|
          lp.slice!(%r{(\[((\d+(;\d+)*))?m)})
          fg_color, bg_color, effects =  self.default_fg, self.default_bg, self.default_effect if $1 && !$2
          fg_color, bg_color, effects = decipher($3, fg_color, bg_color, effects) if $1 && $2
          body_content << %{<span style="background-color:#{bg_color}; color: #{fg_color}">#{lp}</span>}
        end
        body_content << "<br />"
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