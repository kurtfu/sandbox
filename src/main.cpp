/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <cstddef>
#include <cstdlib>
#include <format>
#include <iostream>
#include <span>
#include <string_view>

/*****************************************************************************/
/*** FREE FUNCTIONS **********************************************************/

static void help()
{
    std::cout << "Usage: sandbox [OPTION]" << '\n'
              << '\n'
              << "Options:" << '\n'
              << "  -m, --message=<prompt>  Message to be printed(default: 'hello, world')" << '\n';
}

static std::string_view extract_option_value(std::string_view input)
{
    if (auto index = input.find('='); index != std::string_view::npos)
    {
        return input.substr(index + 1);
    }

    return "";
}

/*****************************************************************************/
/*** MAIN APPLICATION ********************************************************/

int main(int argc, const char* argv[])
{
    std::string_view message = "hello, world";

    argv += 1;  // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
    argc -= 1;

    for (std::string_view token : std::span<const char*>(argv, static_cast<std::size_t>(argc)))
    {
        if (token == "-h" || token == "--help")
        {
            help();
            return 0;
        }

        if (token.starts_with("-m") || token.starts_with("--message"))
        {
            message = extract_option_value(token);
            continue;
        }

        std::cerr << std::format("error: unrecognized argument '{}'", token) << '\n';
        return EXIT_FAILURE;
    }

    std::cout << message << '\n';
    return 0;
}
