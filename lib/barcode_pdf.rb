class BarcodePDF
  
  ENCODINGS = {
    "0" => [ 0x6,  0x4 ],
    "1" => [ 0x11, 0x4 ],
    "2" => [ 0x9,  0x4 ],
    "3" => [ 0x18, 0x4 ],
    "4" => [ 0x5,  0x4 ],
    "5" => [ 0x14, 0x4 ],
    "6" => [ 0xC,  0x4 ],
    "7" => [ 0x3,  0x4 ],
    "8" => [ 0x12, 0x4 ],
    "9" => [ 0xA,  0x4 ],
    "T" => [ 0x6,  0x1 ],
    "O" => [ 0x14, 0x1 ],
    "M" => [ 0x18, 0x1 ],
    "*" => [ 0x6,  0x8 ]
  }
  
  def self.draw_content(content, pdf)
    content = "*#{content.to_s}*"
    content_length = content.length
    
    bar_width_narrow = pdf.bounds.width.to_f / (content_length * 13 - 1)
    bar_width_wide = bar_width_narrow * 2
    
    pos_x = 0
    pos_y = pdf.bounds.height
    
    content.each_byte do |byte|
      current_char = byte.chr
      encoding = ENCODINGS[current_char]
      next if !encoding
          
      4.downto 0 do |bit|
        wide_bar = (encoding[0] & 1 << bit) > 0
        current_bar_width = (wide_bar) ? bar_width_wide : bar_width_narrow
        pdf.rectangle [pos_x, pos_y], current_bar_width, pos_y
        
        pos_x += current_bar_width
      
        if bit > 0
          wide_bar = (encoding[1] & 1 << (bit - 1)) > 0
          pos_x += (wide_bar) ? bar_width_wide : bar_width_narrow
        end
      end
                
      pos_x += bar_width_narrow
    end
    
    pdf.fill
  end
end