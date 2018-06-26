package spiffe.api.examples.demo;

import org.springframework.beans.factory.annotation.Value;
import spiffe.api.examples.demo.model.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Controller
public class TasksController {

    @Value("${tasks.service}")
    private String tasksService;

    @Autowired
    private RestTemplate restTemplate;


    @RequestMapping("/tasks")
    public String index(Model model) {
        model.addAttribute("tasks", getTasks());
        return "tasks";
    }

    @SuppressWarnings("unchecked")
    private List<Task> getTasks() {
        return restTemplate.getForObject(tasksService, List.class);
    }
}
