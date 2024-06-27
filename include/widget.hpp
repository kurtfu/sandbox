#ifndef WIDGET_HPP
#define WIDGET_HPP

/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

/// \cond
#include <iostream>

/// \endcond

/*****************************************************************************/
/*** DATA TYPES **************************************************************/

struct Widget
{
    Widget()
    {
        std::cout << "Widget()\n";
    }

    Widget(const Widget& /* that */)
    {
        std::cout << "Widget(const Widget&)\n";
    }

    Widget(Widget&& /* that */) noexcept
    {
        std::cout << "Widget(Widget&&)\n";
    }

    ~Widget()
    {
        std::cout << "~Widget()\n";
    }

    Widget& operator=(const Widget& that)
    {
        if (this != &that)
        {
            std::cout << "Widget& operator=(const Widget&)\n";
        }

        return *this;
    }

    Widget& operator=(Widget&& that) noexcept
    {
        if (this != &that)
        {
            std::cout << "Widget& operator=(Widget&&)\n";
        }

        return *this;
    }

    friend bool operator<(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "boll operator<(const Widget&, const Widget&)\n";
        return std::addressof(lhs) < std::addressof(rhs);
    }

    friend bool operator>(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "bool operator<(const Widget&, const Widget&)\n";
        return rhs < lhs;
    }

    friend bool operator<=(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "bool operator<(const Widget&, const Widget&)\n";
        return !(lhs > rhs);
    }

    friend bool operator>=(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "bool operator<(const Widget&, const Widget&)\n";
        return !(lhs < rhs);
    }

    friend bool operator==(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "bool operator==(const Widget&, const Widget&)\n";
        return std::addressof(lhs) == std::addressof(rhs);
    }

    friend bool operator!=(const Widget& lhs, const Widget& rhs)
    {
        std::cout << "bool operator!=(const Widget&, const Widget&)\n";
        return !(lhs == rhs);
    }

    friend std::ostream& operator<<(std::ostream& stream, const Widget& /* rhs */)
    {
        stream << "std::ostream& operator<<(std::ostream&, const Widget&)";
        return stream;
    }

    friend void swap(Widget& /* lhs */, Widget& /* rhs */) noexcept
    {
        std::cout << "void swap(Widget&, Widget&)\n";
    }
};

#endif  // WIDGET_HPP
