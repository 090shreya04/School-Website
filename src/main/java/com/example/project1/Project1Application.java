package com.example.project1;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Bean;
import jakarta.servlet.MultipartConfigElement;

@SpringBootApplication
public class Project1Application extends SpringBootServletInitializer {

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		return application.sources(Project1Application.class);
	}

	public static void main(String[] args) {
		SpringApplication.run(Project1Application.class, args);
	}

	@Bean
	public ServletRegistrationBean<UpdateProfileServlet> updateProfileServlet() {
		ServletRegistrationBean<UpdateProfileServlet> reg = new ServletRegistrationBean<>(new UpdateProfileServlet(),
				"/UpdateProfileServlet");
		// 10MB file max, 50MB request total, 0 file threshold
		reg.setMultipartConfig(new MultipartConfigElement("", 10485760, 52428800, 0));
		return reg;
	}

	@Bean
	public ServletRegistrationBean<AddStudentServlet> addStudentServlet() {
		return new ServletRegistrationBean<>(new AddStudentServlet(), "/AddStudentServlet");
	}

	@Bean
	public ServletRegistrationBean<EditStudentServlet> editStudentServlet() {
		return new ServletRegistrationBean<>(new EditStudentServlet(), "/EditStudentServlet");
	}
}
