/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include "cli.hpp"
#include "ini_parser.hpp"

#include <csignal>
#include <cstdlib>
#include <format>
#include <iostream>
#include <map>
#include <span>
#include <string>
#include <string_view>
#include <tuple>
#include <utility>

/*****************************************************************************/
/*** FREE FUNCTIONS **********************************************************/

static void help()
{
    std::cout << "Usage: sandbox [OPTION]" << '\n'
              << "Options:" << '\n'
              << "  -c, --config=<file>  Path of the configuration file" << '\n';
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
/*** CLASSES *****************************************************************/

class Service
{
public:
    void init(std::string_view file)
    {
        auto config = ini_parser::result_t::from_file(file);
        auto name = config.get<std::string>("core", "name");

        m_name = std::move(name);
    }

    void run()
    {
        m_active = true;

        while (m_active)
        {
            auto input = cli::input();
            auto index = input.find(' ');

            auto cmd = input.substr(0, index);
            auto args = (index == std::string::npos) ? "" : input.substr(index + 1);

            if (cmd.empty())
            {
                continue;
            }

            if (auto handler = m_commands.find(cmd); handler == m_commands.end())
            {
                cli::println(std::format("error: invalid command '{}'", cmd));
            }
            else
            {
                auto [_, func] = *handler;
                (this->*func)(args);
            }
        }
    }

    void stop()
    {
        m_active = false;
    }

private:
    void quit(std::string_view /* args */)
    {
        stop();
    }

    std::string m_name;

    volatile bool m_active = false;

    std::map<std::string, void (Service::*)(std::string_view)> m_commands = {
        {"quit", &Service::quit},
    };
};

/*****************************************************************************/
/*** MAIN APPLICATION ********************************************************/

int main(int argc, const char* argv[])
{
    argv += 1;  // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
    argc -= 1;

    std::string_view file;

    for (std::string_view token : std::span<const char*>(argv, static_cast<std::size_t>(argc)))
    {
        if (token == "-h" || token == "--help")
        {
            help();
            return 0;
        }

        if (token.starts_with("-c") || token.starts_with("--config"))
        {
            file = extract_option_value(token);
            continue;
        }

        std::cerr << std::format("error: unrecognized argument '{}'", token) << '\n';
        help();

        return EXIT_FAILURE;
    }

    static Service service{};

    if (!file.empty())
    {
        service.init(file);
    }

    auto signal_handler = [](int) {
        service.stop();
    };

    std::ignore = std::signal(SIGINT, signal_handler);
    service.run();

    std::cout << "goodbye, world\n";
    return 0;
}
