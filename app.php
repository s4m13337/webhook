<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BikeFixUp Webhook Admin</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <h1>BikeFixUp WebHook Admin</h1>
    <div class="nav">
        <ul>
            <li><a href="#" onclick="logViewer(this);return false;">Log Viewer</a></li>
            <li><a href="#" onclick="settings(this);return false;">Settings</a></li>
        </ul>
    </div>
    <div class="content"></div>
    <script>
        let navItems = document.querySelectorAll(".nav ul li a")
        navItems[0].classList.add("active")
        initialize()
        function initialize(){
            let content = document.querySelector(".content")
            content.innerHTML = "<h2>Log Viewer</h2>"
        }

        function toggleActive(item){
            navItems.forEach(i => i.classList.remove("active"))
            item.classList.add("active")
        }

        function logViewer(item) {
            let content = document.querySelector(".content")
            toggleActive(item)
            content.innerHTML = "<h2>Log Viewer</h2>"
        }

        function settings(item) {
            let content = document.querySelector(".content")
            toggleActive(item)
            content.innerHTML = "<h2>Settings</h2>"
        }
    </script>
</body>

</html>