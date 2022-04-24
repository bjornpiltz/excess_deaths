library(extrafont)

# this line is not very portable. You might need to remove the references to ETBembo below
font_import(paths = "~/Library/Fonts/ETBembo", pattern = "*et*", prompt = FALSE)

font_family = "ETBembo-RomanLF"

#  A drop in replacement for ggsave since I have trouble making ggsave respect my fonts
gsave = function (filename, plot = last_plot(), scale = 1, width = NA, height = NA, dpi = 300) 
{
  w = scale*dpi*width
  h = scale*dpi*height 
  png(filename, width = scale*dpi*width, height = scale*dpi*height, res = dpi)
  print(plot)
  dev.off()
}

theme_set(theme_minimal() + 
  theme(text = element_text(family = font_family),
        plot.background = element_rect(fill = "white", color = "white")))
