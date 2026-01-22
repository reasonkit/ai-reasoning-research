-- ============================================================================
-- REASONKIT VISUAL ENHANCEMENTS LUA FILTER
-- Master filter for premium visual quality
-- Version: 2.0.0 | January 2026
-- ============================================================================

-- Track document statistics
local stats = {
  sections = 0,
  figures = 0,
  tables = 0,
  code_blocks = 0,
  blockquotes = 0,
  protocol_boxes = 0
}

-- ============================================================================
-- DROPCAPS: Elegant chapter/section openings
-- ============================================================================

local first_para_of_section = true
local current_section_level = 0

function Header(el)
  if el.level <= 2 then
    first_para_of_section = true
    current_section_level = el.level
    stats.sections = stats.sections + 1
  end
  return el
end

function Para(el)
  -- Add drop cap to first paragraph after section headers
  if first_para_of_section and current_section_level == 1 and #el.content > 0 then
    first_para_of_section = false

    -- Get first character
    local first_inline = el.content[1]
    if first_inline.t == "Str" and #first_inline.text > 0 then
      local first_char = first_inline.text:sub(1, 1)
      local rest = first_inline.text:sub(2)

      -- Only apply to letters
      if first_char:match("%a") then
        -- LaTeX drop cap (requires lettrine package - fallback to large letter)
        local dropcap = pandoc.RawInline('latex',
          '{\\fontsize{36}{42}\\selectfont\\textcolor{RKPurple}{' .. first_char .. '}}\\hspace{0.05em}')

        -- Replace first element
        if rest ~= "" then
          el.content[1] = pandoc.Str(rest)
          table.insert(el.content, 1, dropcap)
        else
          el.content[1] = dropcap
        end
      end
    end
  else
    first_para_of_section = false
  end

  return el
end

-- ============================================================================
-- SMART SPACING: Improve spacing around elements
-- ============================================================================

function BlockQuote(el)
  stats.blockquotes = stats.blockquotes + 1

  -- Add visual enhancement to blockquotes
  local latex_begin = "\\begin{quote}\\itshape\n"
  local latex_end = "\n\\end{quote}"

  local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
  return pandoc.RawBlock('latex', latex_begin .. content .. latex_end)
end

-- ============================================================================
-- HORIZONTAL RULES: Premium styling
-- ============================================================================

function HorizontalRule()
  -- Replace standard hr with gradient line
  local latex = [[
\vspace{1em}
\begin{center}
\begin{tikzpicture}
  \shade[left color=RKCyan,middle color=RKPurple,right color=RKPink]
    (0,0) rectangle (0.6\textwidth,0.5pt);
  \fill[RKPurple] (0.3\textwidth,0) circle (2pt);
\end{tikzpicture}
\end{center}
\vspace{1em}
]]
  return pandoc.RawBlock('latex', latex)
end

-- ============================================================================
-- DOCUMENT METADATA: Add stats at end
-- ============================================================================

function Pandoc(doc)
  -- Insert document stats as LaTeX comment at end
  local stats_comment = string.format([[

%% ============================================================================
%% REASONKIT DOCUMENT STATISTICS
%% Sections: %d | Tables: %d | Figures: %d | Code Blocks: %d
%% Blockquotes: %d | Protocol Boxes: %d
%% ============================================================================

]], stats.sections, stats.tables, stats.figures, stats.code_blocks,
    stats.blockquotes, stats.protocol_boxes)

  table.insert(doc.blocks, pandoc.RawBlock('latex', stats_comment))

  return doc
end

-- ============================================================================
-- EMPHASIS ENHANCEMENT: Better em/strong styling
-- ============================================================================

function Emph(el)
  -- Keep standard emphasis
  return el
end

function Strong(el)
  -- Check for special patterns
  local text = pandoc.utils.stringify(el)

  -- Highlight key terms with color
  if text:match("^Key:") or text:match("^Important:") then
    return pandoc.RawInline('latex',
      '\\textcolor{RKCyan}{\\textbf{' .. text .. '}}')
  end

  return el
end

-- ============================================================================
-- LINKS: Premium URL styling
-- ============================================================================

function Link(el)
  -- Add small arrow icon after external links
  local url = el.target
  if url:match("^https?://") then
    -- External link - add subtle indicator
    local content = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '\\href{' .. url .. '}{' .. content .. '}\\textsuperscript{\\tiny\\,\\textcolor{RKCyan}{↗}}')
  end
  return el
end

-- ============================================================================
-- RETURN FILTER CHAIN
-- ============================================================================

return {
  {Header = Header},
  {Para = Para},
  {BlockQuote = BlockQuote},
  {HorizontalRule = HorizontalRule},
  {Strong = Strong},
  {Link = Link},
  {Pandoc = Pandoc}
}
