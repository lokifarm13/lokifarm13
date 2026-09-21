#!/bin/bash
name=${1:-my-project}
mkdir -p "$name/css" "$name/js"
cat > "$name/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>My Project</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <h1>Hello!</h1>
  <script src="js/script.js"></script>
</body>
</html>
EOF
echo "body { font-family: sans-serif; }" > "$name/css/style.css"
echo "console.log('Hello!');" > "$name/js/script.js"
echo "Структура создана в $name/"