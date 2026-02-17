function generate_icons {
    dart run flutter_launcher_icons
}

function flutter_pub_get {
    flutter pub get
}

function run_tests {
    flutter test
}

case "$1" in
    "generate_icons")
        generate_icons
        ;;
    "flutter_pub_get")
        flutter_pub_get
        ;;
    "run_tests")
        run_tests
        ;;
    *)
        echo "Unknown command: $1"
        echo "Available commands:"
        echo "generate_icons"
        echo "flutter_pub_get"
        echo "run_tests"
        ;;
esac
