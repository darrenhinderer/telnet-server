#taken from the dorkbuster gem

module ANSI
  Reset   = "0"
  Bright  = "1"
  
  Black   = "30"
  Red     = "31"
  Green   = "32"
  Yellow  = "33"
  Blue    = "34"
  Magenta = "35"
  Cyan    = "36"
  White   = "37"
  
  BGBlack   = "40"
  BGRed     = "41"
  BGGreen   = "42"
  BGYellow  = "43"
  BGBlue    = "44"
  BGMagenta = "45"
  BGCyan    = "46"
  BGWhite   = "47"
  
  Bright_Magenta  = Bright+';'+BGBlack+';'+Magenta  #   "1;35;40"

  class << self
    def color(*colors)
      "\033[#{colors.join(';')}m"
    end
    
    def colorize(str, start_color, end_color = Reset)
      "#{color(start_color)}#{str}#{color(end_color)}"
    end

    def attr_is_fgcolor?(str)
      str.to_i.between?(30, 37)
    end
    
    def attr_is_bgcolor?(str)
      str.to_i.between?(40, 47)
    end
    
    def strip(str)
      str.gsub(/\e\[[\d;]*[A-Za-z]/, "")
    end

    def strlen(str)
      str.strip.length
    end
    
    def strclip(str, len)
      out = ""
      nout = 0
      str.scan(/\e\[[\d;]*[A-Za-z]|[^\e]/) do |tok|
        if tok[0] != ?\e
          nout += 1
          break if nout > len
        end
        out << tok
      end
      out
    end

    def strbreak(str, len)
      out = []
      buf = ""
      nout = 0
      str.scan(/\e\[[\d;]*[A-Za-z]|[^\e]/) do |tok|
        if tok[0] != ?\e
          nout += 1
          if nout > len
	    out << buf
	    nout -= len
	    buf = ""
	  end
        end
        buf << tok
      end
      out << buf unless buf.empty?
      out
    end
    
    def red(str);     colorize(str, Red) end
    def green(str);   colorize(str, Green) end
    def yellow(str);  colorize(str, Yellow) end
    def blue(str);    colorize(str, Blue) end
    def magenta(str); colorize(str, Magenta) end
    def cyan(str);    colorize(str, Cyan) end
  
    def bright_magenta(str); colorize(str, Bright_Magenta) end
  
    def set_scroll_fullscreen; "\e[r" end
    def set_scroll_region(row_start, row_end); "\e[#{row_start};#{row_end}r" end
    
    def set_cursor_pos(row, col); "\e[#{row};#{col}H" end
    
    def cursor_left(cnt=1);  "\e[#{cnt}D" end
    def cursor_right(cnt=1); "\e[#{cnt}C" end
    def cursor_up(cnt=1);    "\e[#{cnt}A" end
    def cursor_down(cnt=1);  "\e[#{cnt}B" end
    
    def save_cursor_pos;    "\e[s" end
    def restore_cursor_pos; "\e[u" end

    def backspace_rubout(cnt=1); ("\b \b" * cnt) end
    
    def erase_line; "\e[2K" end
    def erase_eol; "\e[K" end

  end
end



if $0 == __FILE__
  require 'test/unit'

  class TestANSI < Test::Unit::TestCase

    def test_strclip
      assert_equal( "ab\e[34;56mc", ANSI.strclip("ab\e[34;56mcd", 3) )
      assert_equal( "ab\e[34;56mc\e[12;34r\e[H", ANSI.strclip("ab\e[34;56mc\e[12;34r\e[Hd", 3) )
      assert_equal( "ab\e[34;56mc\e[12;34r\e[Hd", ANSI.strclip("ab\e[34;56mc\e[12;34r\e[Hde", 4) )
      assert_equal( "ab\e[34;56mc\e[12;34r\e[Hde", ANSI.strclip("ab\e[34;56mc\e[12;34r\e[Hde", 5) )
    end

    def test_strbreak
      assert_equal( ["ab\e[34;56mc", "d"], ANSI.strbreak("ab\e[34;56mcd", 3) )
      assert_equal( ["ab\e[34;56m", "c\e[12;34r\e[Hd", "e"], ANSI.strbreak("ab\e[34;56mc\e[12;34r\e[Hde", 2) )
    end
    
  end

end


