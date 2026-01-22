-- ============================================================================
-- REASONKIT PROTOCOL BOXES LUA FILTER (Premium Edition)
-- Advanced protocol box handling with visual enhancements
-- Version: 2.0.0 | January 2026
-- ============================================================================

-- Protocol box configurations
local protocols = {
  gigathink = {
    env = "gigathinkbox",
    color = "GigaThinkColor",
    icon = "💡",
    title = "GigaThink — Divergent Exploration"
  },
  laserlogic = {
    env = "laserlogicbox",
    color = "LaserLogicColor",
    icon = "🎯",
    title = "LaserLogic — Convergent Analysis"
  },
  bedrock = {
    env = "bedrockbox",
    color = "BedRockColor",
    icon = "🪨",
    title = "BedRock — Evidence Grounding"
  },
  proofguard = {
    env = "proofguardbox",
    color = "ProofGuardColor",
    icon = "🛡️",
    title = "ProofGuard — Verification"
  },
  brutalhonesty = {
    env = "brutalhonestybox",
    color = "BrutalHonestyColor",
    icon = "⚠️",
    title = "BrutalHonesty — Critical Assessment"
  }
}

-- Track protocol usage for document summary
local protocol_usage = {}

-- ============================================================================
-- DIV ELEMENT PROCESSING
-- ============================================================================

function Div(el)
  -- Check each protocol type
  for class, config in pairs(protocols) do
    if el.classes:includes(class) then
      -- Track usage
      protocol_usage[class] = (protocol_usage[class] or 0) + 1

      -- Get optional title override
      local title = el.attributes.title or config.title

      -- Get optional options
      local options = ""
      if el.attributes.notitle == "true" then
        options = "[notitle]"
      end

      -- Build LaTeX
      local latex_begin = "\\begin{" .. config.env .. "}" .. options .. "\n"
      local latex_end = "\n\\end{" .. config.env .. "}"

      -- Convert content
      local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')

      return pandoc.RawBlock('latex', latex_begin .. content .. latex_end)
    end
  end

  -- Check for generic reasonkit box
  if el.classes:includes("reasonkit") then
    local title = el.attributes.title or "ReasonKit Note"
    local latex_begin = "\\begin{reasonkitbox}{" .. title .. "}\n"
    local latex_end = "\n\\end{reasonkitbox}"
    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    return pandoc.RawBlock('latex', latex_begin .. content .. latex_end)
  end

  -- Check for callout boxes (common markdown extension)
  local callout_types = {
    note = {color = "RKCyan", icon = "ℹ️", title = "Note"},
    tip = {color = "BedRockColor", icon = "💡", title = "Tip"},
    important = {color = "RKPurple", icon = "❗", title = "Important"},
    warning = {color = "ProofGuardColor", icon = "⚠️", title = "Warning"},
    caution = {color = "BrutalHonestyColor", icon = "🔥", title = "Caution"}
  }

  for class, config in pairs(callout_types) do
    if el.classes:includes(class) then
      local title = el.attributes.title or config.title
      local latex = string.format([[
\begin{tcolorbox}[
  enhanced,
  colback=%s!5,
  colframe=%s,
  coltitle=white,
  fonttitle=\bfseries\sffamily,
  title={%s},
  borderline west={3pt}{0pt}{%s},
  breakable,
  boxrule=0.5pt,
  arc=3pt
]
]], config.color, config.color, title, config.color)

      local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
      return pandoc.RawBlock('latex', latex .. content .. "\n\\end{tcolorbox}")
    end
  end

  -- Check for confidence indicator
  if el.classes:includes("confidence") then
    local value = el.attributes.value or "85"
    local latex = "\\confidencemargin{" .. value .. "}\n"
    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    return pandoc.RawBlock('latex', latex .. content)
  end

  -- Check for validated content
  if el.classes:includes("validated") then
    local latex = "\\validatedmargin{}\n"
    local content = pandoc.write(pandoc.Pandoc(el.content), 'latex')
    return pandoc.RawBlock('latex', latex .. content)
  end

  return el
end

-- ============================================================================
-- SPAN PROCESSING (Inline protocol references)
-- ============================================================================

function Span(el)
  -- Protocol name inline styling
  local inline_protocols = {
    gigathink = "\\gigathink{}",
    laserlogic = "\\laserlogic{}",
    bedrock = "\\bedrock{}",
    proofguard = "\\proofguard{}",
    brutalhonesty = "\\brutalhonesty{}"
  }

  for class, latex in pairs(inline_protocols) do
    if el.classes:includes(class) then
      return pandoc.RawInline('latex', latex)
    end
  end

  -- Protocol badge (small colored badge)
  if el.classes:includes("badge") then
    local text = pandoc.utils.stringify(el.content)
    local color = el.attributes.color or "RKPurple"
    return pandoc.RawInline('latex',
      '\\tikz[baseline=-0.5ex]{\\node[fill=' .. color ..
      ',text=white,rounded corners=2pt,inner sep=2pt,font=\\tiny\\bfseries]{' ..
      text .. '};}')
  end

  -- Hex badge
  if el.classes:includes("hexbadge") then
    local text = pandoc.utils.stringify(el.content)
    return pandoc.RawInline('latex',
      '\\begin{tikzpicture}[baseline=-0.5ex]' ..
      '\\node[regular polygon,regular polygon sides=6,minimum size=0.6cm,' ..
      'draw=RKPurple,line width=0.3mm,fill=RKPurple!10,text=RKCyan,font=\\tiny\\bfseries]' ..
      '{' .. text .. '};\\end{tikzpicture}')
  end

  return el
end

-- ============================================================================
-- CODE BLOCK PROCESSING
-- ============================================================================

function CodeBlock(el)
  -- Protocol JSON blocks
  if el.classes:includes("protocol") or el.classes:includes("json") then
    local code = el.text:gsub("\\", "\\textbackslash{}")
    code = code:gsub("{", "\\{"):gsub("}", "\\}")

    local latex = [[
\begin{tcolorbox}[
  enhanced,
  colback=RKDeepBlack,
  colframe=RKCyan,
  boxrule=0.5pt,
  arc=2pt,
  left=5pt,
  right=5pt,
  fontupper=\ttfamily\small\color{white},
  breakable
]
]] .. code .. [[

\end{tcolorbox}
]]
    return pandoc.RawBlock('latex', latex)
  end

  -- Numbered code blocks
  if el.classes:includes("numbered") then
    local lang = el.classes[1] or ""
    if lang == "numbered" then lang = el.classes[2] or "" end

    local code = el.text
    local lines = {}
    local n = 1
    for line in code:gmatch("[^\n]+") do
      table.insert(lines, string.format("\\textcolor{RKTextMuted}{\\scriptsize %3d} │ %s", n, line))
      n = n + 1
    end

    local latex = [[
\begin{tcolorbox}[
  enhanced,
  colback=RKSurface!10,
  colframe=RKPurple,
  boxrule=0.5pt,
  arc=2pt,
  fontupper=\ttfamily\small,
  breakable
]
]] .. table.concat(lines, "\\\\\n") .. [[

\end{tcolorbox}
]]
    return pandoc.RawBlock('latex', latex)
  end

  return el
end

-- ============================================================================
-- DOCUMENT METADATA: Protocol summary
-- ============================================================================

function Pandoc(doc)
  -- Add protocol usage summary if any were used
  if next(protocol_usage) then
    local summary = "\n%% Protocol Usage: "
    for proto, count in pairs(protocol_usage) do
      summary = summary .. proto .. "=" .. count .. " "
    end
    summary = summary .. "\n"
    table.insert(doc.blocks, pandoc.RawBlock('latex', summary))
  end
  return doc
end

-- ============================================================================
-- RETURN FILTER
-- ============================================================================

return {
  {Div = Div},
  {Span = Span},
  {CodeBlock = CodeBlock},
  {Pandoc = Pandoc}
}
