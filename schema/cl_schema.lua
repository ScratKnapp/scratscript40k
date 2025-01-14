function Schema:ExampleFunction(text, ...)
  if text:sub(1, 1) == "@" then text = L(text:sub(2), ...) end
  LocalPlayer():ChatPrint(text)
end
