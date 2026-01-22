-- ============================================================================
-- REASONKIT TYPOGRAPHY LUA FILTER
-- Advanced typographic enhancements for premium output
-- Version: 2.0.0 | January 2026
-- ============================================================================

-- ============================================================================
-- SMART PUNCTUATION & TYPOGRAPHY
-- ============================================================================

-- Replace straight quotes with curly quotes (backup for markdown smart)
function Str(el)
  local text = el.text

  -- En-dash between numbers (e.g., 2022-2025 → 2022–2025)
  text = text:gsub("(%d)%-(%d)", "%1–%2")

  -- Ellipsis
  text = text:gsub("%.%.%.", "…")

  -- Fix common typography issues
  -- Em-dash spacing (remove spaces around em-dash)
  text = text:gsub(" ?— ?", "—")

  -- Percent sign spacing
  text = text:gsub("(%d)%%", "%1\\,\\%%")

  return pandoc.Str(text)
end

-- ============================================================================
-- ABBREVIATION SMALL CAPS
-- ============================================================================

-- Common abbreviations to render in small caps
local abbreviations = {
  ["AI"] = true,
  ["LLM"] = true,
  ["LLMs"] = true,
  ["NLP"] = true,
  ["GPU"] = true,
  ["GPUs"] = true,
  ["CPU"] = true,
  ["CPUs"] = true,
  ["API"] = true,
  ["APIs"] = true,
  ["URL"] = true,
  ["URLs"] = true,
  ["PDF"] = true,
  ["HTML"] = true,
  ["JSON"] = true,
  ["YAML"] = true,
  ["XML"] = true,
  ["SQL"] = true,
  ["RLHF"] = true,
  ["RLVR"] = true,
  ["PRM"] = true,
  ["PRMs"] = true,
  ["CoT"] = true,
  ["ToT"] = true
}

function process_abbreviations(el)
  if abbreviations[el.text] then
    -- Render as small caps
    return pandoc.RawInline('latex',
      '\\textsc{\\MakeLowercase{' .. el.text .. '}}')
  end
  return el
end

-- ============================================================================
-- NUMBERS & UNITS FORMATTING
-- ============================================================================

function format_numbers(el)
  local text = el.text

  -- Large numbers with thin spaces (e.g., 14429 → 14\,429)
  text = text:gsub("(%d)(%d%d%d)([^%d])", "%1\\,%2%3")
  text = text:gsub("(%d)(%d%d%d)$", "%1\\,%2")
  text = text:gsub("^(%d)(%d%d%d)", "%1\\,%2")

  -- Percentage handling
  if text:match("%d+%%") then
    text = text:gsub("(%d+)%%", "%1\\,\\%%")
  end

  -- Temperature (°C, °F)
  text = text:gsub("(%d+)°([CF])", "%1°\\,%2")

  if text ~= el.text then
    return pandoc.RawInline('latex', text)
  end
  return el
end

-- ============================================================================
-- FRACTIONS & MATH IMPROVEMENTS
-- ============================================================================

function Span(el)
  -- Check for fraction class
  if el.classes:includes("frac") then
    local text = pandoc.utils.stringify(el.content)
    -- Parse fraction like "1/2"
    local num, den = text:match("(%d+)/(%d+)")
    if num and den then
      return pandoc.RawInline('latex',
        '\\nicefrac{' .. num .. '}{' .. den .. '}')
    end
  end

  -- Check for oldstyle numbers
  if el.classes:includes("oldstyle") then
    local text = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '{\\addfontfeature{Numbers=OldStyle}' .. text .. '}')
  end

  -- Check for lining numbers
  if el.classes:includes("lining") then
    local text = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '{\\addfontfeature{Numbers=Lining}' .. text .. '}')
  end

  return el
end

-- ============================================================================
-- ORDINALS
-- ============================================================================

function process_ordinals(text)
  -- 1st, 2nd, 3rd, 4th etc → superscript
  text = text:gsub("(%d+)(st)([^%w])", "%1\\textsuperscript{%2}%3")
  text = text:gsub("(%d+)(nd)([^%w])", "%1\\textsuperscript{%2}%3")
  text = text:gsub("(%d+)(rd)([^%w])", "%1\\textsuperscript{%2}%3")
  text = text:gsub("(%d+)(th)([^%w])", "%1\\textsuperscript{%2}%3")
  return text
end

-- ============================================================================
-- COMBINED STR PROCESSOR
-- ============================================================================

function Str_combined(el)
  local text = el.text

  -- Apply ordinal processing
  local has_ordinal = text:match("%d+(st|nd|rd|th)")
  if has_ordinal then
    text = process_ordinals(text)
    return pandoc.RawInline('latex', text)
  end

  -- Check for abbreviations
  if abbreviations[text] then
    return pandoc.RawInline('latex',
      '\\textsc{\\MakeLowercase{' .. text .. '}}')
  end

  -- En-dash between numbers
  if text:match("%d%-%d") then
    text = text:gsub("(%d)%-(%d)", "%1–%2")
    return pandoc.Str(text)
  end

  return el
end

-- ============================================================================
-- RETURN FILTER
-- ============================================================================

return {
  {Str = Str_combined},
  {Span = Span}
}
