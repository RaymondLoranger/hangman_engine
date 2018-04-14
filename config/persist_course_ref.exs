use Mix.Config

config :hangman_dictionary,
  course_ref:
    """
    Based on the course [Elixir for Programmers](https://codestool.
    coding-gnome.com/courses/elixir-for-programmers) by Dave Thomas.
    """
    |> String.replace("\n", "")
