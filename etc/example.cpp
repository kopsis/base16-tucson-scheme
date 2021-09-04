#include <vector>
#include <string>
#include <iostream>

struct MenuOption { std::string title; };
// Menu is a vector of MenuOption: options can be inserted, removed, reordered...
// and has a title.
class Menu : public std::vector<MenuOption> {
public:
    std::string title = "UNTITLED";

    void print() const {
        std::cout << title << ":\n";
        for (std::size_t i = 0, s = size(); i < s; ++i)
            std::cout << "  " << (i+1) << ". " << at(i).title << '\n';
    }
};
