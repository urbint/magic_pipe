defmodule PipetteTest do
  use ExUnit.Case, async: true

  import Pipette

  describe "pipette" do
    def inc(x), do: x + 1
    def add(x, y), do: x + y
    def return_true(), do: true
    def return_false(), do: false

    test "conditionally pipes through the bodies of succeeding tests" do
      result =
        pipette 1 do
          inc()                            # 2
          if return_true(), do: inc()      # 3
          if return_false(), do: inc()     # 3
          if return_true(), do: inc()      # 4
          if return_true(), do: add(3)     # 7
          unless return_true(), do: add(3) # 7
          cond do
            return_true()  -> inc()        # 8
            return_false() -> inc()
          end
          case return_true() do
            true  -> inc()                 # 9
            false -> add(2)
          end
        end

      assert result == 9
    end

    test "supports `else` blocks for `if`" do
      result =
        pipette 1 do
          if return_false() do
            add(2)
          else
            inc() # 2
          end
        end

      assert result == 2
    end

    test "supports `else` blocks for `unless` (but you shouldn't use them)" do
      result =
        pipette 1 do
          unless return_false() do
            add(2) # 3
          else
            inc()
          end
        end

      assert result == 3
    end
  end
end