-- register l: JS debug logging macro (yank word, wrap in console.debug)
vim.fn.setreg("l", 'yoconsole.debug("pa", pa);')
