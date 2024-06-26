/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

/// \cond
#include <csignal>
#include <exception>
#include <iostream>
#include <tuple>

/// \endcond

/*****************************************************************************/
/*** DATA TYPES **************************************************************/

class Service
{
public:
    void start()
    {
        m_active = true;

        while (m_active)
        {}
    }

    void stop() noexcept
    {
        m_active = false;
    }

private:
    bool m_active = false;
};

/*****************************************************************************/
/*** MAIN APPLICATION ********************************************************/

int main()
{
    static Service service{};

    try
    {
        auto signal_handler = [](int)
        {
            std::cout << "SIGINT received!\n";
            service.stop();
        };

        std::ignore = std::signal(SIGINT, signal_handler);
        service.start();
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << '\n';
        service.stop();
    }

    std::cout << "goodbye, world\n";
    return 0;
}
