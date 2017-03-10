#include "catch.hpp"

#include <PROJECT_NAME_HERE/temp.hpp>

TEST_CASE("Temp", "[temp]") {
  REQUIRE(35 == 7 * 5 );
  REQUIRE(25 == 5 * 5 );
  REQUIRE(15 == 3 * 5 );
  REQUIRE(temp() == 42);
}
