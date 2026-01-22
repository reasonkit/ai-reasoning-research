-- ============================================================================
-- REASONKIT MARGIN ANNOTATIONS LUA FILTER (Premium Edition)
-- Advanced margin notes for reasoning audit trail
-- Version: 2.0.0 | January 2026
-- ============================================================================

-- Track current context
local current_protocol = nil
local current_section = ""
local section_depth = 0

-- ============================================================================
-- HEADER PROCESSING: Track sections and add protocol markers
-- ============================================================================

function Header(el)
  section_depth = el.level
  current_section = pandoc.utils.stringify(el.content)

  -- Check for protocol attribute
  if el.attributes.protocol then
    current_protocol = el.attributes.protocol
  end

  -- Add protocol marker after section header
  if current_protocol and el.attributes["show-protocol"] ~= "false" then
    local proto_abbrev = current_protocol:sub(1, 2):upper()

    -- Return header followed by margin annotation
    return {
      el,
      pandoc.RawBlock('latex',
        "\\protocolmargin{" .. proto_abbrev .. "}{" .. current_protocol:upper() .. "}")
    }
  end

  return el
end

-- ============================================================================
-- PARAGRAPH PROCESSING: Confidence and validation markers
-- ============================================================================

function Para(el)
  local annotations = {}

  -- Check first span for confidence
  for _, item in ipairs(el.content) do
    if item.t == "Span" then
      -- Confidence indicator
      if item.attributes.confidence then
        local conf = item.attributes.confidence
        table.insert(annotations, "\\confidencemargin{" .. conf .. "}")
      end

      -- Validation marker
      if item.classes:includes("validated") then
        table.insert(annotations, "\\validatedmargin{}")
      end

      -- Citation strength
      if item.attributes.citations then
        local count = item.attributes.citations
        table.insert(annotations, "\\marginnote{\\tiny\\textcolor{RKTextMuted}{" .. count .. " citations}}")
      end
    end
  end

  -- Add annotations at start of paragraph
  if #annotations > 0 then
    local latex = table.concat(annotations, "\n") .. "\n"
    table.insert(el.content, 1, pandoc.RawInline('latex', latex))
  end

  return el
end

-- ============================================================================
-- BLOCK PROCESSING: Fallacy warnings and other annotations
-- ============================================================================

function Div(el)
  local annotations = {}

  -- Fallacy warning
  if el.attributes.fallacy then
    local fallacy = el.attributes.fallacy
    annotations[#annotations + 1] = "\\fallacymargin{" .. fallacy .. "}"
  end

  -- Evidence level
  if el.attributes.evidence then
    local level = el.attributes.evidence
    local color = "RKTextMuted"
    if level == "strong" then color = "BedRockColor"
    elseif level == "moderate" then color = "ProofGuardColor"
    elseif level == "weak" then color = "BrutalHonestyColor"
    end
    annotations[#annotations + 1] = "\\marginnote{\\tiny\\textcolor{" .. color .. "}{Evidence: " .. level .. "}}"
  end

  -- Source tier
  if el.attributes.tier then
    local tier = el.attributes.tier
    annotations[#annotations + 1] = "\\marginnote{\\tiny\\textcolor{RKCyan}{Tier " .. tier .. " source}}"
  end

  -- Validation status
  if el.attributes.validated == "true" then
    annotations[#annotations + 1] = "\\validatedmargin{}"
  end

  -- Add annotations if any
  if #annotations > 0 then
    local latex_prefix = table.concat(annotations, "\n") .. "\n"
    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    return pandoc.RawBlock('latex', latex_prefix .. content)
  end

  return el
end

-- ============================================================================
-- SPAN PROCESSING: Inline annotations
-- ============================================================================

function Span(el)
  -- Inline confidence
  if el.attributes.confidence then
    local conf = el.attributes.confidence
    local text = pandoc.utils.stringify(el.content)

    -- Add small confidence indicator after text
    return pandoc.RawInline('latex',
      text .. '\\textsuperscript{\\tiny\\textcolor{RKCyan}{' .. conf .. '\\%%}}')
  end

  -- Inline source citation
  if el.classes:includes("source") then
    local text = pandoc.utils.stringify(el.content)
    local tier = el.attributes.tier or "1"
    local color = tier == "1" and "BedRockColor" or "RKTextMuted"

    return pandoc.RawInline('latex',
      '\\textcolor{' .. color .. '}{[' .. text .. ']}')
  end

  -- Inline claim marker
  if el.classes:includes("claim") then
    local text = pandoc.utils.stringify(el.content)
    local verified = el.attributes.verified or "pending"

    local marker = ""
    if verified == "true" then
      marker = "\\textcolor{BedRockColor}{✓}"
    elseif verified == "false" then
      marker = "\\textcolor{BrutalHonestyColor}{✗}"
    else
      marker = "\\textcolor{ProofGuardColor}{?}"
    end

    return pandoc.RawInline('latex', text .. '\\textsuperscript{' .. marker .. '}')
  end

  return el
end

-- ============================================================================
-- METADATA: Add audit trail metadata to PDF
-- ============================================================================

function Meta(meta)
  -- Add ReasonKit metadata
  meta["pdf-metadata"] = meta["pdf-metadata"] or {}
  meta["pdf-metadata"].creator = pandoc.MetaString("ReasonKit Protocol System v2.0")

  -- Add protocol chain if defined
  if meta.reasonkit and meta.reasonkit.protocols then
    local protos = {}
    for _, p in ipairs(meta.reasonkit.protocols) do
      table.insert(protos, pandoc.utils.stringify(p))
    end
    meta["pdf-metadata"].keywords = pandoc.MetaString(table.concat(protos, ", "))
  end

  return meta
end

-- ============================================================================
-- RETURN FILTER
-- ============================================================================

return {
  {Header = Header},
  {Para = Para},
  {Div = Div},
  {Span = Span},
  {Meta = Meta}
}
