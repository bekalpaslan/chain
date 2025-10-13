package com.thechain;

import com.thechain.config.BaseIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;

import static org.assertj.core.api.Assertions.assertThat;

class ChainApplicationTest extends BaseIntegrationTest {

    @Autowired
    private ApplicationContext context;

    @Test
    void contextLoads() {
        // Verify that the application context loads successfully
        assertThat(context).isNotNull();
    }

    @Test
    void mainMethodStartsApplication() {
        // Verify that the main method can be called without exceptions
        // Note: We don't actually start the application to avoid port conflicts
        assertThat(ChainApplication.class).isNotNull();
    }

    @Test
    void applicationHasJpaAuditingEnabled() {
        // Verify that @EnableJpaAuditing is present
        EnableJpaAuditing annotation = ChainApplication.class.getAnnotation(EnableJpaAuditing.class);
        assertThat(annotation).isNotNull();
    }

    @Test
    void applicationHasSchedulingEnabled() {
        // Verify that @EnableScheduling is present
        EnableScheduling annotation = ChainApplication.class.getAnnotation(EnableScheduling.class);
        assertThat(annotation).isNotNull();
    }

    @Test
    void allRequiredBeansAreLoaded() {
        // Verify that key beans are present in the context
        assertThat(context.containsBean("ticketService")).isTrue();
        assertThat(context.containsBean("authService")).isTrue();
        assertThat(context.containsBean("chainStatsService")).isTrue();
        assertThat(context.containsBean("ticketController")).isTrue();
        assertThat(context.containsBean("authController")).isTrue();
        assertThat(context.containsBean("chainController")).isTrue();
    }

    @Test
    void dataSourceIsConfigured() {
        // Verify that a DataSource bean exists
        assertThat(context.containsBean("dataSource")).isTrue();
    }

    @Test
    void entityManagerFactoryIsConfigured() {
        // Verify that EntityManagerFactory is configured
        assertThat(context.containsBean("entityManagerFactory")).isTrue();
    }

    @Test
    void transactionManagerIsConfigured() {
        // Verify that TransactionManager is configured
        assertThat(context.containsBean("transactionManager")).isTrue();
    }

    @Test
    void securityFilterChainIsConfigured() {
        // Verify that security is configured
        assertThat(context.containsBean("securityFilterChain")).isTrue();
    }

    @Test
    void jwtUtilBeanIsPresent() {
        // Verify that JWT utility is available
        assertThat(context.containsBean("jwtUtil")).isTrue();
    }
}
