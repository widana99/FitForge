import re

files = [
    r'c:\Users\Lenovo\.gemini\antigravity\scratch\fitforge\lib\services\data\upper_body_db.dart',
    r'c:\Users\Lenovo\.gemini\antigravity\scratch\fitforge\lib\services\data\core_glutes_db.dart',
    r'c:\Users\Lenovo\.gemini\antigravity\scratch\fitforge\lib\services\data\lower_full_db.dart'
]

for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We want to replace the 'focus': '...' line with a clean one based on the 'tags': [...] line directly below it
    
    # Let's split by exercises block. Each block starts with 'xxx': { and ends with }
    
    def replacer(match):
        block = match.group(0)
        
        # Analyze tags
        target = "Seluruh Tubuh"
        if "'Lengan'" in block or "'Bahu'" in block:
            target = "Pektoral, Lengan & Bahu"
        elif "'Perut'" in block:
            target = "Otot Inti (Core / Abdomen)"
        elif "'Bokong'" in block:
            target = "Gluteus & Pinggul"
        elif "'Kaki'" in block:
            target = "Quadrisep & Paha"
        elif "'Seluruh Tubuh'" in block:
            target = "Kardio & Fungsional"
            
        # Replace the focus line
        new_block = re.sub(r"'focus':\s*'.*?',", f"'focus': '{target}',", block)
        return new_block
        
    # Match an entire block like: 'something': { ... },
    # Assuming standard formatting
    new_content = re.sub(r"'[a-zA-Z0-9_]+':\s*\{.*?(?=\},\n|\}\n|,\n  '|$)", replacer, content, flags=re.DOTALL)
    
    # Just in case regex was slightly off due to nested dicts, let's just use a simpler line-by-line state machine
    lines = content.split('\n')
    output_lines = []
    
    current_target = "Target"
    i = 0
    while i < len(lines):
        line = lines[i]
        
        if "'focus':" in line:
            # Look ahead for tags line
            tags_line = ""
            for j in range(i+1, min(i+5, len(lines))):
                if "'tags':" in lines[j]:
                    tags_line = lines[j]
                    break
            
            target = "Seluruh Tubuh"
            if "'Lengan'" in tags_line: target = "Pektoral, Lengan & Bahu"
            elif "'Perut'" in tags_line: target = "Otot Inti (Core / Abdomen)"
            elif "'Bokong'" in tags_line: target = "Gluteus & Pinggul"
            elif "'Kaki'" in tags_line: target = "Quadrisep & Hamstring"
            elif "'Seluruh Tubuh'" in tags_line: target = "Kardiovaskular"
            
            # replace the entire line, but keep indentation
            indent = line[:line.find("'focus'")]
            output_lines.append(f"{indent}'focus': '{target}',")
        else:
            output_lines.append(line)
        i += 1

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(output_lines))
        
print("Success!")
