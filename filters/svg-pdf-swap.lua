-- Lua filter for Pandoc: Swap image extensions based on output format
-- For LaTeX/PDF output: Use .pdf (LaTeX doesn't support SVG natively)
-- For HTML output: Use .svg (native browser support, smaller size)

function Image(elem)
  local src = elem.src

  if FORMAT:match('latex') or FORMAT:match('pdf') then
    -- For PDF output, ensure we use .pdf extension
    if src:match('%.svg$') then
      elem.src = src:gsub('%.svg$', '.pdf')
    end
  elseif FORMAT:match('html') then
    -- For HTML output, ensure we use .svg extension
    if src:match('%.pdf$') then
      elem.src = src:gsub('%.pdf$', '.svg')
    end
  end

  return elem
end
