if exists('g:loaded_persisted') | finish | endif

command! SessionStart :lua require("persisted").start()
command! SessionStop :lua require("persisted").stop()
command! SessionSave :lua require("persisted").save()
command! SessionLoad :lua require("persisted").load()
command! -nargs=1 SessionLoadFromFile :lua require("persisted").load({ session = <f-args> })
command! SessionLoadLast :lua require("persisted").load({ last = true })
command! SessionDelete :lua require("persisted").delete()
command! SessionToggle :lua require("persisted").toggle()

let g:loaded_persisted = 1
