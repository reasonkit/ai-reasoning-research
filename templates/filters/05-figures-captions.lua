-- ============================================================================
-- REASONKIT FIGURES & CAPTIONS LUA FILTER
-- Enhanced figure handling with visual improvements
-- Version: 2.0.0 | January 2026
-- ============================================================================

-- Figure counter
local figure_count = 0

-- ============================================================================
-- IMAGE PROCESSING
-- ============================================================================

function Image(el)
  figure_count = figure_count + 1

  local src = el.src
  local alt = pandoc.utils.stringify(el.caption) or ""
  local title = el.title or ""

  -- Check for figure attributes
  local width = el.attributes.width or "0.8\\textwidth"
  local is_float = el.attributes.float ~= "false"
  local position = el.attributes.position or "htbp"
  local border = el.attributes.border == "true"

  -- Caption text (use alt text if no title)
  local caption = title ~= "" and title or alt

  -- Build LaTeX
  local latex_parts = {}

  if is_float then
    table.insert(latex_parts, "\\begin{figure}[" .. position .. "]")
    table.insert(latex_parts, "\\centering")
  else
    table.insert(latex_parts, "\\begin{center}")
  end

  -- Image with optional border
  if border then
    table.insert(latex_parts, "\\fbox{%")
    table.insert(latex_parts, "  \\includegraphics[width=" .. width .. "]{" .. src .. "}%")
    table.insert(latex_parts, "}")
  else
    table.insert(latex_parts, "\\includegraphics[width=" .. width .. "]{" .. src .. "}")
  end

  -- Caption with styling
  if caption ~= "" and is_float then
    table.insert(latex_parts, "\\caption{\\small " .. caption .. "}")
    table.insert(latex_parts, "\\label{fig:figure" .. figure_count .. "}")
  end

  if is_float then
    table.insert(latex_parts, "\\end{figure}")
  else
    -- Non-float caption
    if caption ~= "" then
      table.insert(latex_parts, "")
      table.insert(latex_parts, "\\textit{\\small\\textcolor{RKTextMuted}{" .. caption .. "}}")
    end
    table.insert(latex_parts, "\\end{center}")
  end

  return pandoc.RawInline('latex', table.concat(latex_parts, "\n"))
end

-- ============================================================================
-- FIGURE DIV PROCESSING (for grouped figures)
-- ============================================================================

function Div(el)
  -- Check for figure class
  if el.classes:includes("figure") then
    figure_count = figure_count + 1

    local caption = el.attributes.caption or ""
    local position = el.attributes.position or "htbp"
    local width = el.attributes.width or "0.9\\textwidth"

    local latex_parts = {}

    table.insert(latex_parts, "\\begin{figure}[" .. position .. "]")
    table.insert(latex_parts, "\\centering")

    -- Process content
    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    table.insert(latex_parts, content)

    if caption ~= "" then
      table.insert(latex_parts, "\\caption{" .. caption .. "}")
      table.insert(latex_parts, "\\label{fig:figure" .. figure_count .. "}")
    end

    table.insert(latex_parts, "\\end{figure}")

    return pandoc.RawBlock('latex', table.concat(latex_parts, "\n"))
  end

  -- Check for subfigure class
  if el.classes:includes("subfigure") then
    local width = el.attributes.width or "0.45\\textwidth"
    local caption = el.attributes.caption or ""

    local latex_parts = {}

    table.insert(latex_parts, "\\begin{subfigure}[b]{" .. width .. "}")
    table.insert(latex_parts, "\\centering")

    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    table.insert(latex_parts, content)

    if caption ~= "" then
      table.insert(latex_parts, "\\caption{" .. caption .. "}")
    end

    table.insert(latex_parts, "\\end{subfigure}")

    return pandoc.RawBlock('latex', table.concat(latex_parts, "\n"))
  end

  return el
end

-- ============================================================================
-- CAPTION SPAN PROCESSING
-- ============================================================================

function Span(el)
  -- Custom figure reference
  if el.classes:includes("figref") then
    local num = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '\\textcolor{RKCyan}{Figure~' .. num .. '}')
  end

  -- Custom table reference
  if el.classes:includes("tabref") then
    local num = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '\\textcolor{RKPurple}{Table~' .. num .. '}')
  end

  return el
end

-- ============================================================================
-- RETURN FILTER
-- ============================================================================

return {
  {Image = Image},
  {Div = Div},
  {Span = Span}
}
